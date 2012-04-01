require 'spec_helper'

describe StaleIfSlow::TimeoutPerformer do
  
  describe "when generating performers" do
    it "should generate a new instance of TimeoutPerformer" do
      performer = StaleIfSlow::TimeoutPerformer.generate({})
      performer.should be_an_instance_of StaleIfSlow::TimeoutPerformer
    end
  end
  
  describe "when initializing" do
    let :reference do
      OpenStruct.new(method: 1)
    end
    
    let :original_impl do
      lambda {}
    end

    subject do
      StaleIfSlow::TimeoutPerformer.new reference: reference, method: :method, &original_impl
    end
    
    it "should keep a copy of reference" do
      subject.reference.should eql reference
    end
    
    it "should keep a copy of method" do
      subject.method.should eql :method
    end
    
    it "should keep a copy of the original implementation of method" do
      subject.block.should eql original_impl
    end
    
    it "should create a new instance of KeyGenerator" do
      subject.key_generator.should be_an_instance_of StaleIfSlow::KeyGenerator
    end
        
    describe "and retrieving options from StaleIfSlow.config" do
      before do
        StaleIfSlow.config.stub(:[])
      end
      
      after do
        StaleIfSlow::TimeoutPerformer.new({}, &original_impl)
      end
      
      it "should retrieve cache_store configuration" do
        StaleIfSlow.config.should_receive(:[]).with(:cache_store)
      end
    
      it "should retrieve timeout configuration" do
        StaleIfSlow.config.should_receive(:[]).with(:timeout)
      end
    
      it "should retrieve content_timeout configuration" do
        StaleIfSlow.config.should_receive(:[]).with(:content_timeout)
      end
    
      it "should retrieve stale_content_timeout configuration" do
        StaleIfSlow.config.should_receive(:[]).with(:stale_content_timeout)
      end      
    end
    
    describe "and overriding some defaults" do
      subject do
        StaleIfSlow::TimeoutPerformer.new({
          reference: reference,
          method: :method,
          opts: {timeout: 0.1, content_timeout: 30.seconds, stale_content_timeout: 5.minutes}
        }, &original_impl)
      end
      
      it "should override timeout value" do
        subject.timeout.should eql 0.1
      end
      
      it "should override content timeout value" do
        subject.content_timeout.to_i.should eql 30.seconds.to_i
      end
      
      it "should override stale content timeout" do
        subject.stale_content_timeout.to_i.should eql 5.minutes.to_i
      end
    end
  end
  
  describe "when execute method call" do
    class Example4
      include StaleIfSlow::API  
      stale_if_slow :get, :error
      def get; 7 end
      def error; raise "error"; end
    end
    
    let :performer do
      reference.stale_if_slow_performers[:get]
    end
        
    let! :reference do
      Example4.new
    end
    
    let :original_method do
      "#{StaleIfSlow::API::PREFIX}get"
    end
                  
    before do
      StaleIfSlow::TimeoutPerformer.stub(:generate).and_return(performer)
      StaleIfSlow.configure { logger_level Logger::ERROR }
    end
    
    it "should return cached content if cache is still hot" do
      reference.get.should eql 7
      cache_key = performer.cache_key
      performer.send(:read_referer, cache_key).should_not be_nil
      performer.send(:read, cache_key).should_not be_nil
      
      performer.cache_store.should_not_receive(:write)
      reference.get.should eql 7
    end
    
    describe "and cache already expired" do
      
      before do
        reference.get
        referer_key = performer.send(:slow_cache_referer, performer.cache_key)
        performer.cache_store.delete(referer_key).should be_true
      end
      
      describe "and have cached content" do
        
        before do
          performer.cache_store.read(performer.cache_key).should_not be_nil
        end
        
        it "should wait the configured timeout and refresh the cache" do
          performer.should_receive(:timeout_execution).and_return(7)
          performer.should_receive(:write_content).with(performer.cache_key, 7)
          reference.get
        end
        
        it "should return stale content if a StaleIfSlow::Error occur" do
          performer.stub(:read_referer).and_return(nil)
          performer.send(:write_content, performer.cache_key, "stale") # Overrides the stale value to guarantee that a cached
                                                                       # value was received
          performer.should_receive(:timeout_execution).and_raise(StaleIfSlow::Error)
          performer.should_not_receive(:write_content)
          reference.should_not_receive(original_method)
          reference.get.should eql "stale"
        end
        
        it "should propagate the exception in case of error" do
          reference.should_not_receive(original_method)
          reference.stub(original_method).and_raise(StandardError.new("erro"))
          expect { reference.get }.to raise_error
        end
      end
      
      describe "and does not have cached content" do
        it "should complete the call" do
          reference.should_receive(original_method)
          reference.get
        end
      end
    end
  end
  
end