require "sinatra/activerecord/rake"

task :environment do
  ENV['RACK_ENV'] ||= 'development'
  require './config/boot.rb'
end


namespace :crawlers do
  task :aa_feed => :environment do
    parser = AndroidArsenalFeedParser.new(1, 63)
    compile_statements = parser.process_feed
  end

  task :aa => :environment do
    parser = AndroidArsenalParser.new(1, 63)
    compile_statements = parser.parse
  end
end

namespace :utils do
  task :compute, [:library_name] => :environment do |t, args|
  	puts args[:library_name]
    LibraryMethodsCount.new(args[:library_name]).compute_dependencies()
  end
end
