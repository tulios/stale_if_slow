require "logger"
require "timeout"
require "digest/md5"
require "active_support"

require_relative "stale_if_slow/version"
require_relative "stale_if_slow/config"
require_relative "stale_if_slow/api"
require_relative "stale_if_slow/timeout_performer"
require_relative "stale_if_slow/key_generator"
require_relative 'stale_if_slow/railtie.rb' if defined?(Rails)

module StaleIfSlow
  class Error < StandardError; end
  
  class << self
    
    def config
      @@config ||= StaleIfSlow::Config.new
    end
    
    def configure settings_hash = nil, &block
      config.apply!(settings_hash, &block)
      log :info, "Initialized"
      true
    end
    
    def log type, message
      config[:logger].send(type, "[StaleIfSlow] :: #{message}")
    end
    
  end  
end