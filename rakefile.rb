require './app/model'
require 'sinatra/activerecord/rake'

task :environment do
  ENV['RACK_ENV'] ||= 'development'
  require './config/boot.rb'
end

namespace :crawlers do

  # Process libraries from android arsenal (feed rss)
  # ~$ rake crawlers:aa_feed
  task :aa_feed => :environment do
    parser = AndroidArsenalFeedParser.new(1, 63)
    compile_statements = parser.process_feed
  end

  # Process libraries from android arsenal
  # ~$ rake crawlers:aa
  task :aa => :environment do
    parser = AndroidArsenalParser.new(1, 63)
    compile_statements = parser.process
  end

  # Creates a list of libs from bintray
  # ~$ rake crawlers:bintray
  task :bintray => :environment do
    parser = BintrayParser.new(0, 292)
    compile_statements = parser.parse

    File.open("bintray_list", 'w') { |file| file.write(compile_statements) }
  end
end

# Compute methods count for given lib name
# ~$ rake compute <lib name>
task :compute => :environment do
  library_name = ARGV.last
  LibraryMethodsCount.new(library_name).compute_dependencies()
end
