require 'spec_helper'

describe StaleIfSlow::TimeoutPerformer do
  
  describe "when generating performers" do
    it "should generate a new instance of TimeoutPerformer" do
      performer = StaleIfSlow::TimeoutPerformer.generate({})
      performer.should be_an_instance_of StaleIfSlow::TimeoutPerformer
    end
  end
  
  describe "when initializing" do
    it "should keep a copy of reference" do
      
    end
    
    it "should keep a copy of method" do
      
    end
    
    it "should keep a copy of the original implementation of method" do
      
    end
    
    it "should create a new instance of KeyGenerator" do
      
    end
    
    it "should retrieve cache_store configuration" do
      
    end
    
    it "should retrieve timeout configuration" do
      
    end
    
    it "should retrieve content_timeout configuration" do
      
    end
    
    it "should retrieve stale_content_timeout configuration" do
      
    end
  end
  
  describe "when execute method call" do
    it "should return cached content if cache is still hot" do
      
    end
    
    describe "and cache already expired" do
      describe "and have cached content" do
        it "should wait the configured timeout and refresh the cache" do
          
        end
        
        it "should return stale content if a StaleIfSlow::Error occur" do
          
        end
        
        it "should propagate the exception in case of error" do
          
        end
      end
      
      describe "and does not have cached content" do
        it "should complete the call" do
          
        end
      end
    end
  end
  
end