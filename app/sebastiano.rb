require 'sinatra/base'
require 'json'
require 'sinatra/namespace'
require 'active_record'

class Sebastiano < Sinatra::Base

  register Sinatra::Namespace

  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/../static'

  FORMAT_SUFFIXES = ['@aa', '@jar']

  before {
    env["rack.errors"] =  ERROR_LOG
  }


  ### Base endpoints ###
  get '/' do
    File.read(File.join(File.dirname(__FILE__) + '/../static', 'index.html'))
  end

  get '/health' do
    db_available = DBService.connected?
    queue_available = QueueService.connected?

    # In rare cases the DB connection drops completely at runtime.
    # In that case, it's better to mark the instance as unhealthy.
    # Also in case of high db load, if the connection
    # timesout, the instance is removed. Maybe this should be fixed at
    # some point, by using just the desired db error.
    status (db_available ? 200 : 502)

    body ({
            db_up: db_available,
            queue_up: queue_available
    }.to_json)
  end


  ### APIs ###
  namespace '/api' do

    ## Frontend APIs ##
    get '/stats/:lib_name' do
      content_type :json
      library_name = params[:lib_name]

      result = {}
      status = ""

      # handle '+' libraries
      if library_name.end_with?("+")
        ends_with_plus = true
        LOGGER.info "[GET] ends with plus!"
        plus_lib = LibraryStatus.where(library_name: library_name).first
        if plus_lib and plus_lib.status == "processing"
          LOGGER.info "[GET] plus_lib status: processing"
          status = plus_lib.status
        elsif plus_lib
          LOGGER.info "[GET] plus_lib status: #{plus_lib.status}"
          parts = library_name.split(/:/)
          most_recent = Libraries.where(["group_id = ? and artifact_id = ?", parts[0], parts[1]]).order(version: :desc).first
          status = plus_lib.status
          result = LibraryMethodsCount.new(most_recent.fqn).compute_dependencies()
          most_recent.increment("hit_count")
          if most_recent.creation_time == 0
            library_entry.update_column("creation_time", Time.now.to_i)
          end
          most_recent.update_column("last_updated", Time.now.to_i)
          most_recent.save!
        else
          LOGGER.info "[GET] cannot find status"
        end
      end

      library_status = LibraryStatus.where(library_name: library_name).first

      # handle libraries with version
      if not ends_with_plus
        if library_status
          if library_status.status == "done"
            result = LibraryMethodsCount.new(library_name).compute_dependencies()
            status = library_status.status
            if library_name.end_with?("+")
              parts = library_name.split(/:/)
              library_entry = Libraries.where(["group_id = ? and artifact_id = ? and version = ?", parts[0], parts[1], parts[2]]).first
            else
              library_entry = Libraries.find_by_fqn(library_name)
            end
            library_entry.increment("hit_count")
            library_entry.update_column("creation_time", Time.now.to_i)
            library_entry.update_column("last_updated", Time.now.to_i)
            library_entry.save!
          elsif library_status.status == "processing"
            status = library_status.status
          elsif library_status.status == "error"
            status = library_status.status
          end
        else
          status = "undefined"
        end
      end

      {
        :status => status,
        :lib_name => library_name,
        :result => result
      }.to_json
    end


    post '/request/:lib_name' do |argument|
      content_type :json
      library_name = params[:lib_name].gsub(/(#{FORMAT_SUFFIXES.join('|')})$/, '')

      must_calculate = true

      # handle '+' libraries
      if library_name.end_with?("+")
        parts = library_name.split(/:/)
        most_recent = Libraries.where(["group_id = ? and artifact_id = ?", parts[0], parts[1]]).order(version: :desc).first
        time_limit = (Time.now.to_i - 7 * 24 * 60 * 60)
        if most_recent
          LOGGER.info "[POST] creation_time: #{most_recent.creation_time}"
          LOGGER.info "[POST] time limit: #{time_limit}"
        end
        if most_recent and most_recent.last_updated > time_limit
          LOGGER.info "[POST] inside time limit!"
          new_lib = LibraryStatus.where(library_name: library_name).first_or_create
          new_lib.status = "done"
          new_lib.save!
          must_calculate = false
        else
          LOGGER.info "[POST] empty or outside time frame, calculating.."
          LibraryStatus.where(library_name: library_name).destroy_all
        end
      end

      # handle libraries with version
      lib_status = LibraryStatus.where(library_name: library_name).first_or_create
      if must_calculate && lib_status.status.to_s.empty?
        lib_status.status = "processing"
        lib_status.save!

        if ENV['RACK_ENV'] == 'production'
          QueueService.enqeue(
            {lib_name: library_name}
          )
        else
          process_library(library_name)
        end
      end

      {
        :enqueued => true,
        :lib_name => library_name
      }.to_json
    end


    get '/top/' do
      content_type :json
      top = Libraries.order(hit_count: :desc).distinct(true).take(100)
      top.to_json
    end

    ## Workers APIs ##
    post '/aa' do
      content_type :json
      Thread.new do
        parser = AndroidArsenalFeedParser.new(1, 63)
        compile_statements = parser.process_feed
      end
    end


    post '/process_lib' do
      content_type :json
      request.body.rewind
      payload = JSON.parse(request.body.read)
      library_name = payload['lib_name']

      process_library(library_name)
    end
  end


  private

  def process_library(library_name)
    lib_status = LibraryStatus.where(library_name: library_name).first
    begin
      LibraryMethodsCount.new(library_name).compute_dependencies()
      lib_status.status = "done"
    rescue Exception => e
      LOGGER.error "Failure, error is: #{e}"
      LOGGER.error "Backtrace: #{e.backtrace}"
      lib_status.status = "error"
    ensure
      lib_status.save!
    end
  end
end
