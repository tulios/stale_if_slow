require 'spec_helper'

describe StaleIfSlow::Config do
  
  let! :store do
    ActiveSupport::Cache.lookup_store(:memory_store)
  end
    
  subject do
    StaleIfSlow::Config.new
  end
  
  before do
    ActiveSupport::Cache.stub(:lookup_store).with(:memory_store).and_return(store)
  end
  
  describe "defaults" do    
    it "should have a cache store value" do
      subject[:cache_store].should eql store
    end
    
    it "should have a logger value" do
      subject[:logger].should_not be_nil
      subject[:logger].should be_an_instance_of(Logger)
    end
    
    it "should have a logger level value" do
      subject[:logger_level].should eql Logger::INFO
    end
    
    it "should have a timeout value" do
      subject[:timeout].should eql 0.3
    end
    
    it "should have a content timeout value" do
      subject[:content_timeout].to_i.should eql 5.minutes.to_i
    end
    
    it "should have a stale content timeout value" do
      subject[:stale_content_timeout].to_i.should eql 30.minutes.to_i
    end
  end
  
  describe "options" do
    it "should have setter methods for each option" do
      StaleIfSlow::Config::OPTIONS.each do |option|
        subject.should respond_to option
        subject.send(option, "value")
      end
      
      StaleIfSlow::Config::OPTIONS.each do |option|
        subject[option].should eql "value"
      end
    end
    
    it "should be accessible through [] method" do
      StaleIfSlow::Config::OPTIONS.each do |option|
        subject[option].should_not be_nil
      end
    end
    
    describe "when configuring" do
      after do
        subject[:cache_store].should eql store
        subject[:logger].should be_instance_of Logger
        subject[:logger_level].should eql Logger::WARN
        subject[:timeout].should eql 0.4
        subject[:content_timeout].to_i.should eql 10.minutes.to_i
        subject[:stale_content_timeout].to_i.should eql 1.hour.to_i
      end
      
      it "should be configured through a block" do
        subject.apply! do
          cache_store ActiveSupport::Cache.lookup_store(:memory_store)
          logger Logger.new(STDOUT)
          logger_level Logger::WARN
          timeout 0.4
          content_timeout 10.minutes
          stale_content_timeout 1.hour
        end      
      end
    
      it "should be configured through a hash" do
        subject.apply!({
          cache_store: ActiveSupport::Cache.lookup_store(:memory_store),
          logger: Logger.new(STDOUT),
          logger_level: Logger::WARN,
          timeout: 0.4,
          content_timeout: 10.minutes,
          stale_content_timeout: 1.hour
        })      
      end
    end
    
  end
end
