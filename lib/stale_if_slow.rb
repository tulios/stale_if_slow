require "logger"
require "timeout"
require 'digest/md5'
require "active_support"

require_relative "stale_if_slow/version"
require_relative "stale_if_slow/config"
require_relative "stale_if_slow/api"
require_relative "stale_if_slow/timeout_performer"
require_relative "stale_if_slow/key_generator"

module StaleIfSlow
  class Error < StandardError; end
  
  class << self
    
    def config
      @@config ||= Config.new
    end
    
    def configure &block
      config.apply!(&block)
      true
    end
    
    def log type, message
      config[:logger].send(type, "[StaleIfSlow] :: #{message}")
    end
    
  end  
end