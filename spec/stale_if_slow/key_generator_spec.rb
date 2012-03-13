require 'spec_helper'

describe StaleIfSlow::KeyGenerator do
  
  let :reference do
    Object.new
  end
  
  let :method_name do
    :my_method
  end
  
  describe "with default generator" do
    subject do
      StaleIfSlow::KeyGenerator.new reference, method_name
    end
        
    it "should consider the class/method and args in account" do
      args = [nil]
      key = subject.generate(args)
      key.should eql Digest::MD5.hexdigest("#{reference.class}##{method_name}::#{args.join('|')}")
      
      args = [1]
      key2 = subject.generate(args)
      key2.should eql Digest::MD5.hexdigest("#{reference.class}##{method_name}::#{args.join('|')}")
      
      key.should_not eql key2
    end
  end
  
  describe "with lambda generator" do
    subject do
      StaleIfSlow::KeyGenerator.new reference, method_name, &generator
    end
    
    let :generator do
      lambda {|method_name, reference, args| "#{reference.class}|#{method_name}|#{args.join('|')}"}
    end
    
    it "should take in account the value of lambda" do
      args = [nil]
      key = subject.generate(args)
      key.should eql "#{reference.class}|#{method_name}|#{args.join('|')}"
      
      args = [1]
      key2 = subject.generate(args)
      key2.should eql "#{reference.class}|#{method_name}|#{args.join('|')}"
      
      key.should_not eql key2
    end
  end
  
  describe "with class generator" do
    class Generator
      def initialize method_name, reference, args
        @reference, @method_name, @args = reference, method_name, args
      end
      
      def generate
        "#{@reference.class}|#{@method_name}|#{@args.join('|')}"
      end
    end
    
    subject do
      StaleIfSlow::KeyGenerator.new reference, method_name, Generator
    end
    
    it "should call generate without args" do
      args = [nil]
      key = subject.generate(args)
      key.should eql "#{reference.class}|#{method_name}|#{args.join('|')}"
      
      args = [1]
      key2 = subject.generate(args)
      key2.should eql "#{reference.class}|#{method_name}|#{args.join('|')}"
      
      key.should_not eql key2
    end
      
  end
end
