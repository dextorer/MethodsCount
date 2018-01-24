module MethodsCount
  module Routes
    class Website < Sinatra::Application

      set :views, 'app/views'
      set :public_folder, File.dirname(__FILE__) + '/../static'

      ### Base endpoints ###
      get '/' do
        @active = :index
        erb :index, layout: :master
      end

      get '/index.html' do
        params = ('?' + request.query_string) unless request.query_string.empty?
        redirect '/' + params.to_s, 301
      end

      get '/about' do
        @active = :about
        erb :about, layout: :master
      end

      get '/plugins' do
        @active = :plugins
        erb :plugins, layout: :master
      end
    end
  end
end
