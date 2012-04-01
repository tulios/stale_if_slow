module StaleIfSlow
  module API
    PREFIX = "stale_if_slow_original_"
    
    def self.included base
      base.extend ClassMethods
    end
    
    def initialize_stale_if_slow
      self.class.class_eval do
        attr_accessor :stale_if_slow_performers
      end
      
      self.class.stale_if_slow_for_methods.each do |config|
        params = self.class.send(:stale_if_slow_config_extractor, config)
        self.class.send(:stale_if_slow_rename_instance_method, params[:method], self)
        self.class.send(:stale_if_slow_proxy_for_instance_method, params.merge(reference: self))
      end
      
      self
    end
        
    module ClassMethods
      def new *args
        obj = super(*args)
        obj.initialize_stale_if_slow
      end
          
      def self.extended klass
        class << klass
          attr_accessor :stale_if_slow_for_methods
          attr_accessor :stale_if_slow_for_class_methods
        end        
        
        klass.stale_if_slow_for_methods = []
        klass.stale_if_slow_for_class_methods = []
      end
      
      def stale_if_slow *methods
        self.stale_if_slow_for_methods << methods
        self.stale_if_slow_for_methods.flatten!.uniq!        
      end
      
      private
      def stale_if_slow_config_extractor config
        name, generator, opts = config, nil, {}
        
        if config.is_a?(Hash)
          name = config.keys.first
          value = config.values.first
          
          if value.is_a?(Hash)
            generator, opts = value.delete(:key), value
          else
            generator = value
          end
        end
        
        {method: name, generator: generator, opts: opts}
      end
      
      def stale_if_slow_rename_class_method name, reference
        klass = (class << reference; self; end)
        new_name = "#{PREFIX}#{name}"
        klass.send(:alias_method, new_name, name)
        klass.send(:private, new_name)
        klass
      end
      
      def stale_if_slow_rename_instance_method name, reference
        reference.class.instance_eval do
          new_name = "#{PREFIX}#{name}"
          alias_method new_name, name
          private new_name
        end
      end
      
      def stale_if_slow_proxy_for_class_method klass, params
        performer = stale_if_slow_new_timeout_performer(params)
          
        klass.send(:define_method, params[:method]) do |*args|
          performer.call(*args)
        end        
      end
      
      def stale_if_slow_proxy_for_instance_method params
        performer = stale_if_slow_new_timeout_performer(params)
        
        params[:reference].stale_if_slow_performers ||= {}
        params[:reference].stale_if_slow_performers[params[:method]] = performer
        
        params[:reference].class.instance_eval do
          define_method(params[:method]) do |*args|
            performer.call(*args)
          end
        end
      end
      
      def stale_if_slow_new_timeout_performer params
        TimeoutPerformer.generate(params) do |*args|
          params[:reference].send("#{PREFIX}#{params[:method]}", *args)
        end
      end
      
      def stale_if_slow_config_for_method name
        stale_if_slow_for_methods.select {|c|
          c.is_a?(Hash) ? c.keys.first == name : c == name
        }.first        
      end
            
      def singleton_method_added name
        super(name)
        name = name.to_sym
        configured_methods = stale_if_slow_for_methods || []        
        
        if configured_methods.include?(name)
          configuration = stale_if_slow_config_for_method(name)
          params = stale_if_slow_config_extractor(configuration)
          stale_if_slow_for_class_methods << stale_if_slow_for_methods.delete(configuration)
      
          klass = stale_if_slow_rename_class_method(name, self)
          stale_if_slow_proxy_for_class_method(klass, params.merge(reference: self))
        end
      end                        
    end
    
  end
end