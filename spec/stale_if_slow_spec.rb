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
    it "should set the configurations on config object" do
      pending
    end
  end
end