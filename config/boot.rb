require 'rubygems'
require 'bundler'
require 'active_support'

env = ENV['RACK_ENV'].to_sym

# Third party deps
Bundler.require

# Logging
::Logger.class_eval { alias :write :'<<' }
if env == :production
  access_log = ::File.new('logs/access.log', 'a+')
  access_log.sync = true
  LOGGER = ::Logger.new(access_log)
  
  ERROR_LOG = ::File.new('logs/error.log', 'a+')
  ERROR_LOG.sync = true
else
  LOGGER = ::Logger.new(STDOUT)
  ERROR_LOG = STDOUT
end

# TODO: when we reach Papertrail quota for the month, dicrease the log level for prod
LOGGER.level = (env == :production ? Logger::WARN : Logger::DEBUG)

# App deps
require_all 'app'
