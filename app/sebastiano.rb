require 'sinatra/base'
require 'json'
require 'sinatra/namespace'
require 'active_record'

class Sebastiano < Sinatra::Base

  register Sinatra::Namespace

  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/../static'

  FORMAT_SUFFIXES = ['@aar', '@jar']

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

  get '/sitemap.xml' do
    content_type :xml
    map = XmlSitemap::Map.new('www.methodscount.com') do |m|
      Libraries.find_each do |lib|
        m.add "/index.html?lib=#{lib.fqn}", :updated => lib.updated_at, :period => :never
      end
    end

    map.render
  end

  ### APIs ###
  namespace '/api' do

    ## Frontend APIs ##
    get '/stats/:lib_name' do
      content_type :json
      library_name = params[:lib_name]

      library_status = LibraryStatus.where(library_name: library_name).first
      status = library_status ? library_status.status : 'undefined'
      LOGGER.info "[GET] lib status: #{status}"

      if status == 'done'
        if library_name.end_with?("+")
          LOGGER.info "[GET] ends with plus!"
          parts = library_name.split(/:/)
          library = Libraries.where(["group_id = ? and artifact_id = ?", parts[0], parts[1]]).order(version: :desc).first
        else
          library = Libraries.find_by_fqn(library_name)
        end

        result = LibraryMethodsCount.new(library.fqn).compute_dependencies()
        library.increment("hit_count")
        library.save!
      end

      {
        :status => status,
        :lib_name => library_name,
        :result => result || {}
      }.to_json
    end


    post '/request/:lib_name' do |argument|
      content_type :json
      library_name = params[:lib_name].gsub(/(#{FORMAT_SUFFIXES.join('|')})$/, '')

      library_status = LibraryStatus.where(library_name: library_name).first_or_create

      if (library_name.end_with?("+") and library_status.updated_at < 1.week.ago) or
        library_status.status.to_s.empty?

        LOGGER.info "[POST] empty or outside time frame, calculating.."
        library_status.status = "processing"
        library_status.save!

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
