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
        
        if config.is_a?(Hash)
          name = config.keys.first
          generator = config.values.first
        end
        
        rename_method name
        define_proxy_method_for name, generator
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
            
    def define_proxy_method_for name, generator
      original_impl = lambda {|*args| self.send("#{PREFIX}#{name}", *args)}
      performer = TimeoutPerformer.generate(reference: self, method: name, generator: generator, &original_impl)
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