module StaleIfSlow
  class Config
    OPTIONS = [:cache_store, :logger, :logger_level, :timeout, :content_timeout, :stale_content_timeout]
    attr_reader :options
    
    def initialize
      @options = {
        cache_store: ActiveSupport::Cache.lookup_store(:memory_store),
        logger: Logger.new(STDOUT),
        logger_level: Logger::INFO,
        timeout: 0.3, # 300 milliseconds
        content_timeout: 5.minutes,
        stale_content_timeout: 30.minutes
      }      
    end
    
    def apply! &block
      instance_exec(&block) if block_given?
      options[:logger].level = options[:logger_level]
    end
      
    OPTIONS.each do |key|
      define_method(key.to_s) do |value|
        @options[key] = value
      end
    end
    
    def [] key
      options[key]
    end
            
  end 
end
