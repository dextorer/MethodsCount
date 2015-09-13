require 'sinatra/base'
require 'json'
require 'sinatra/namespace'
require 'active_record'
require './model'
require './gradle_mock_project/library_methods_count'

class Sebastiano < Sinatra::Base

  register Sinatra::Namespace

  set :static, true
  set :public_folder, File.dirname(__FILE__) + '/static'

  namespace '/api' do

    get '/stats/:lib_name' do
      content_type :json
      puts LibraryStatus.all
      library_name = params[:lib_name]
      library_status = LibraryStatus.where(library_name: library_name).first
      result = {}
      if library_status && library_status.status == "done"
        result = LibraryMethodsCount.new(library_name).compute_dependencies()
      end
      {
        :status => status,
        :result => result,
        :lib_name => library_name
      }.to_json
    end


    post '/request/:lib_name' do |argument|
      content_type :json
      library_name = params[:lib_name]

      if LibraryStatus.where(library_name: library_name).count == 0
        Thread.new(params[:lib_name]) do |library_name|
          begin
            new_lib = LibraryStatus.new
            new_lib.library_name = library_name
            new_lib.status = "processing"
            new_lib.save!
            LibraryMethodsCount.new(library_name).compute_dependencies()
            new_lib.status = "done"
            new_lib.save!
          rescue
            LibraryStatus.where(library_name: library_name).destroy_all
          end
        end
      end

      {
        :enqueued => true,
        :lib_name => library_name
      }.to_json
    end
  end
end
