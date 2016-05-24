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
      
      body ({
              db_up: db_available,
              queue_up: queue_available
      }.to_json)
    end
    
    use Routes::Website
    use Routes::API
  end
end
