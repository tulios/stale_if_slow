require 'spec_helper'

describe StaleIfSlow do
  
  it "should define StaleIfSlow::Error" do
    StaleIfSlow.constants.should include :Error
  end
  
  describe "#config" do
    before do
      StaleIfSlow.class_variable_set("@@config", nil)
    end
    
    it "should generate a new instance of Config" do
      StaleIfSlow::Config.should_receive(:new)
      StaleIfSlow.config
    end
    
    it "should generate a new instance just once" do
      config = StaleIfSlow::Config.new
      StaleIfSlow::Config.should_receive(:new).once.and_return(config)
      3.times { StaleIfSlow.config }
    end
  end
  
  describe "#configure" do
    subject do
      StaleIfSlow.config
    end
      
    let! :store do
      ActiveSupport::Cache.lookup_store(:memory_store)
    end
  
    before do
      ActiveSupport::Cache.stub(:lookup_store).with(:memory_store).and_return(store)
    end
      
    it "should set the configurations on config object" do
      StaleIfSlow.configure do
        cache_store ActiveSupport::Cache.lookup_store(:memory_store)
        logger Logger.new(STDOUT)
        logger_level Logger::WARN
        timeout 0.4
        content_timeout 10.minutes
        stale_content_timeout 1.hour
      end
      
      subject[:cache_store].should eql store
      subject[:logger].should be_instance_of Logger
      subject[:logger_level].should eql Logger::WARN
      subject[:timeout].should eql 0.4
      subject[:content_timeout].to_i.should eql 10.minutes.to_i
      subject[:stale_content_timeout].to_i.should eql 1.hour.to_i
    end
  end
end