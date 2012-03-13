module StaleIfSlow
  class KeyGenerator
    
    def initialize reference, method_name, class_generator = nil, &generator
      @reference, @method_name = reference, method_name
      @generator = default_generator
      @generator = generator || new_class_generator(class_generator) if class_generator or generator
    end
    
    def generate args
      @generator.call(@method_name, @reference, args)
    end
    
    private
    def new_class_generator clazz
      lambda {|method_name, reference, args|
        generator = clazz.new(method_name, reference, args)
        generator.generate
      }
    end
    
    def default_generator
      lambda {|method_name, reference, args|
        Digest::MD5.hexdigest("#{reference.class}##{method_name}::#{args.join('|')}")
      }
    end
    
  end
end