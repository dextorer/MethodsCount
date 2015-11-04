require 'sinatra/base'
require 'json'
require 'sinatra/namespace'
require 'active_record'
require './model'
require './library_methods_count'

class Sebastiano < Sinatra::Base

  register Sinatra::Namespace

  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/static'

  get '/' do
    redirect '/index.html'
  end

  namespace '/api' do

    get '/stats/:lib_name' do
      content_type :json
      library_name = params[:lib_name]

      result = {}
      status = ""

      # handle '+' libraries
      if library_name.end_with?("+")
        ends_with_plus = true
        puts "[GET] ends with plus!"
        plus_lib = LibraryStatus.where(library_name: library_name).first
        if plus_lib and plus_lib.status == "processing"
          puts "[GET] plus_lib status: processing"
          status = plus_lib.status
        elsif plus_lib
          puts "[GET] plus_lib status: #{plus_lib.status}"
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
          puts "[GET] cannot find status"
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
              in_db = library_name
              if library_name.end_with?("@aar") or library_name.end_with?("@jar")
                in_db = library_name.sub(/@aar/, '').sub(/@jar/, '')
              end
              library_entry = Libraries.find_by_fqn(in_db)
            end
            library_entry.increment("hit_count")
            library_entry.update_column("creation_time", Time.now.to_i)
            library_entry.update_column("last_updated", Time.now.to_i)
            library_entry.save!
          elsif library_status.status == "processing"
            status = library_status.status
          elsif library_status.status == "error"
            status = library_status.status
            LibraryStatus.where(library_name: library_name).destroy_all
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
      library_name = params[:lib_name]

      must_calculate = true

      # handle '+' libraries
      if library_name.end_with?("+")  
        parts = library_name.split(/:/)
        most_recent = Libraries.where(["group_id = ? and artifact_id = ?", parts[0], parts[1]]).order(version: :desc).first
        time_limit = (Time.now.to_i - 7 * 24 * 60 * 60)
        if most_recent
          puts "[POST] creation_time: #{most_recent.creation_time}"
          puts "[POST] time limit: #{time_limit}"
        end
        if most_recent and most_recent.last_updated > time_limit
          puts "[POST] inside time limit!"
          new_lib = LibraryStatus.new
          new_lib.library_name = library_name
          new_lib.status = "done"
          new_lib.save!
          must_calculate = false
        else
          puts "[POST] empty or outside time frame, calculating.."
          LibraryStatus.where(library_name: library_name).destroy_all
        end
      end

      # handle libraries with version
      lib_status = LibraryStatus.where(library_name: library_name).first_or_create
      if must_calculate && lib_status.status.to_s.empty?
        lib_status.status = "processing"
        lib_status.save!
        Thread.new(lib_status) do |new_lib_status|
          begin
            LibraryMethodsCount.new(new_lib_status.library_name).compute_dependencies()
            new_lib_status.status = "done"
          rescue => e
            puts "Failure, error is: #{e}"
            puts "Backtrace: #{e.backtrace}"
            new_lib_status.status = "error"
          ensure
            new_lib_status.save!
          end
        end
      end

      {
        :enqueued => true,
        :lib_name => library_name
      }.to_json
    end


    get '/top/' do
      content_type :json
      top = Libraries.order(count: :desc).distinct(true).take(100)
      top.to_json
    end
  end
end
