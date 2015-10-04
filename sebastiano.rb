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

  namespace '/api' do

    get '/stats/:lib_name' do
      content_type :json
      library_name = params[:lib_name]
      library_status = LibraryStatus.where(library_name: library_name).first
      result = {}
      status = ""
      if library_status 
        if library_status.status == "done"
          result = LibraryMethodsCount.new(library_name).compute_dependencies()
          status = library_status.status
        elsif library_status.status == "processing"
          status = library_status.status
        elsif library_status.status == "error"
          status = library_status.status
          LibraryStatus.where(library_name: library_name).destroy_all
        end
      else
        status = "undefined"
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

      if LibraryStatus.where(library_name: library_name).count == 0
        Thread.new(params[:lib_name]) do |library_name|
          new_lib = LibraryStatus.new
          new_lib.library_name = library_name
          begin  
            new_lib.status = "processing"
            new_lib.save!
            LibraryMethodsCount.new(library_name).compute_dependencies()
            new_lib.status = "done"
            new_lib.save!
          rescue
            new_lib.status = "error"
            new_lib.save!
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
      {
        :top_libs => top
      }.to_json
    end
  end
end
