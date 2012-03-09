module StaleIfSlow
  class KeyGenerator
    
    def initialize reference, method_name, generator = nil
      @reference, @method_name = reference, method_name
      @generator = default_generator
      
      if generator
        if generator.is_a?(Proc)
          @generator = generator
          
        elsif generator.is_a?(Class)
          @generator = new_class_generator(generator)
        end
      end
    end
    
    def generate args
      @generator.call(@method_name, @reference, args)
    end
    
    private
    def new_class_generator clazz
      lambda {|method_name, reference, args|
        generator = clazz.new(method_name, reference, args)
        generator.generate.to_s
      }
    end
    
    def default_generator
      lambda {|method_name, reference, args|
        Digest::MD5.hexdigest("#{reference.class}##{method_name}::#{args.join('|')}")
      }
    end
    
  end
end