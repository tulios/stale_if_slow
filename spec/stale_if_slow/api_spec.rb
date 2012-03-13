require 'spec_helper'

describe StaleIfSlow::API do
  class Generator
    def initialize(method_name, reference, args); end
    def generate; "class"; end
  end  
  
  class Example1
    include StaleIfSlow::API  
    stale_if_slow :save
    stale_if_slow find: lambda {"key"}
    stale_if_slow find_all: ::Generator
    def save arg; end
    def find arg=nil; end
    def find_all; end
  end
  
  class Example2
    include StaleIfSlow::API
    stale_if_slow :save, :save, :save, :save
  end
    
  describe "configuration of class" do
    it "should store the methods and generators" do
      Example1.stale_if_slow_for_methods.should_not be_nil
      Example1.stale_if_slow_for_methods.should include :save
      Example1.stale_if_slow_for_methods[1].keys.first.should eql :find
      Example1.stale_if_slow_for_methods[1].values.first.is_a?(Proc).should be_true
      Example1.stale_if_slow_for_methods[2].keys.first.should eql :find_all
      Example1.stale_if_slow_for_methods[2].values.first.should eql Generator
    end
    
    it "should not repeat methods" do
      Example2.stale_if_slow_for_methods.should_not be_nil
      Example2.stale_if_slow_for_methods.should have(1).item
      Example2.stale_if_slow_for_methods.first.should eql :save
    end
  end
  
  describe "when initialized" do
    subject do
      Example1.new
    end
        
    it "should rename the original methods" do
      subject.initialize_stale_if_slow
      subject.private_methods.should include "#{StaleIfSlow::API::PREFIX}#{:save}".to_sym
      subject.private_methods.should include "#{StaleIfSlow::API::PREFIX}#{:find}".to_sym
      subject.private_methods.should include "#{StaleIfSlow::API::PREFIX}#{:find_all}".to_sym
    end
        
    it "should override the configured method" do
      performer = Object.new
      performer.should_receive(:call).with(1).once
      performer.should_receive(:call).with(2).once
      performer.should_receive(:call).once

      StaleIfSlow::TimeoutPerformer.should_receive(:generate).exactly(3).times.and_return(performer)
      
      subject.initialize_stale_if_slow
      subject.save 1
      subject.find 2
      subject.find_all
    end
  end
  
end
