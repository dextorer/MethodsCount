require 'sinatra/base'
require 'json'
require 'sinatra/namespace'
require 'active_record'
require './model'

class Sebastiano < Sinatra::Base

   register Sinatra::Namespace

   set :static, true
   set :public_folder, File.dirname(__FILE__) + '/static'

   namespace '/api' do
      get '/stats/:lib_name' do
         content_type :json
         puts LibraryStatus.all
         status = LibraryStatus.where(library_name: params[:lib_name]).first.status 
         result = {}
         if status == "done"
            result = `./library-method-count.sh #{params[:lib_name]}`
         end
         { 
            :status => status,
            :result => result, 
            :lib_name => params[:lib_name]
         }.to_json
      end

      post '/request/:lib_name' do |argument|
         Thread.new(params[:lib_name]) do |library_name|
            new_lib = LibraryStatus.new
            new_lib.library_name = library_name
            new_lib.status = "processing"
            new_lib.save!
            system('bash library-method-count.sh ' + library_name) 
            new_lib.status = "done"
            new_lib.save!
         end

         {
            :enqueued => true, 
            :lib_name => params[:lib_name] 
         }.to_json
      end
   end
end
