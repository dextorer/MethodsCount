require 'rubygems'
require 'bundler'

env = ENV['RACK_ENV'].to_sym

# Deps

Bundler.require

# Logging

::Logger.class_eval { alias :write :'<<' }
if env == :production
  access_log = ::File.new('logs/access.log', 'a+')
  access_log.sync = true
  LOGGER = ::Logger.new(access_log)
else
  LOGGER = ::Logger.new(STDOUT)
end

LOGGER.level = (env == 'production' ? Logger::ERROR : Logger::DEBUG)

ERROR_LOG = ::File.new('logs/error.log', 'a+')
ERROR_LOG.sync = true

# Main app

require './sebastiano'
