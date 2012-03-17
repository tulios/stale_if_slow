module StaleIfSlow
  class TimeoutPerformer
    
    attr_reader :reference, :method, :block, :key_generator, :cache_store, :timeout, :content_timeout, :stale_content_timeout
    attr_reader :cache_key
    
    def self.generate params, &original_impl
      TimeoutPerformer.new(params, &original_impl)
    end
    
    def initialize params, &block
      opts = params[:opts] || {}
      @reference, @method, @block = params[:reference], params[:method], block
      @key_generator = KeyGenerator.new(@reference, @method, params[:generator])
      
      @cache_store = StaleIfSlow.config[:cache_store]
      @timeout = opts[:timeout] || StaleIfSlow.config[:timeout]
      @content_timeout = opts[:content_timeout] || StaleIfSlow.config[:content_timeout]
      @stale_content_timeout = opts[:stale_content_timeout] || StaleIfSlow.config[:stale_content_timeout]
    end
        
    def call *args
      @cache_key = key_generator.generate(args)
      cached_content = read(cache_key)
      
      log "cache_key: #{cache_key}"
      
      # Valid cache, return
      return cached_content if read_referer(cache_key)
      
      # Stale cache to serve?
      if cached_content
        begin
          # Cache referer invalid, try to refresh
          content = Timeout.timeout(timeout, StaleIfSlow::Error) do
            block.call(*args)
          end
                
          # Refreshed
          log "succeed"
          write_content(cache_key, content)
      
        rescue StandardError => e
          # Timeout Error, return stale
          if e.class == StaleIfSlow::Error
            log "Invalidated by timeout"
            cached_content
        
          else
            log "Invalidated by error (#{e.class}: #{e.message})"
            raise e
          end
        end
        
      # Don't have stale, proceed anyway
      else
        content = block.call(*args)
        write_content(cache_key, content)
      end
    end
    
    private
    def read_referer cache_key
      read(slow_cache_referer(cache_key))
    end
    
    def write_referer cache_key
      write(slow_cache_referer(cache_key), "", expires_in: content_timeout)
    end
        
    def write_content cache_key, content
      write_referer(cache_key)
      write(cache_key, content, expires_in: stale_content_timeout)
    end
    
    def read key
      cache_store.read key
    end
    
    def write key, content, params
      cache_store.write key, content, params
      content
    end
    
    def slow_cache_referer cache_key
      "#{cache_key}_stale_if_slow_key"
    end
    
    def log message
      StaleIfSlow.log :info, "#{reference.class}##{method} :: #{message} - configured timeout: #{timeout}"
    end
    
  end
end