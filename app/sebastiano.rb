require 'sinatra/base'
require 'json'
require 'sinatra/namespace'
require 'active_record'

module Sebastiano
  class App < Sinatra::Base

    set :root, App.root
    set :static, true

    before {
      env["rack.errors"] =  ERROR_LOG
    }

    get '/sitemap.xml' do
      content_type :xml
      map = XmlSitemap::Map.new('www.methodscount.com') do |m|
        m.add 'plugins'
        m.add 'about'
        Libraries.top(200).each do |lib|
          m.add "/?lib=#{lib.fqn}", :updated => lib.updated_at, :period => :never
        end
      end

      map.render
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
          Libraries.top(200).each do |lib|
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

        use Routes::Website
        use Routes::API
      end
    end
