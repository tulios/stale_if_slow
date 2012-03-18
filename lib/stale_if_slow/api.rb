module StaleIfSlow
  module API
    PREFIX = "stale_if_slow_original_"
    
    def self.included base
      base.extend ClassMethods
    end
    
    def initialize_stale_if_slow
      self.class.stale_if_slow_for_methods.each do |config|
        name = config
        generator = nil
        opts = {}
        
        if config.is_a?(Hash)
          name = config.keys.first
          value = config.values.first
          
          if value.is_a?(Hash)
            generator, opts = value.delete(:key), value
          else
            generator = value
          end
          
        end
        
        rename_method name
        define_proxy_method_for name, generator, opts
      end
    end
    
    private
    def rename_method name
      self.class.instance_eval do
        new_name = "#{PREFIX}#{name}"
        alias_method new_name, name
        private new_name
      end
    end
            
    def define_proxy_method_for name, generator, opts
      performer = TimeoutPerformer.generate(reference: self, method: name, generator: generator, opts: opts) do |*args|
        self.send("#{PREFIX}#{name}", *args)
      end
      
      self.class.instance_eval do
        define_method(name) do |*args|
          performer.call(*args)
        end
      end
    end
    
    module ClassMethods
      def self.extended klass
        class << klass
          attr_accessor :stale_if_slow_for_methods
        end

        klass.stale_if_slow_for_methods = []
      end
        
      def stale_if_slow *methods
        self.stale_if_slow_for_methods << methods
        self.stale_if_slow_for_methods.flatten!.uniq!
      end    
    end
    
  end
end