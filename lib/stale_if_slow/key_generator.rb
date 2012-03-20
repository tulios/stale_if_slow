module StaleIfSlow
  class KeyGenerator
    
    def initialize reference, method_name, class_generator = nil, &lambda_generator
      @reference, @method_name = reference, method_name
      @generator = lambda_generator if lambda_generator      
      @generator = class_generator.new(@method_name, @reference) if class_generator.is_a?(Class)
    end
    
    def generate args
      if @generator.respond_to?(:generate)
        @generator.generate(args)        
        
      elsif @generator
        @generator.call(@method_name, @reference, args)
        
      else
        default_key(args)
      end
    end
    
    private
    def default_key args
      "#{@reference.class}##{@method_name}::#{args.join('|')}"
    end
    
  end
end