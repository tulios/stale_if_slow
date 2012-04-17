module StaleIfSlow
  class Railtie < Rails::Railtie
    config.stale_if_slow = ActiveSupport::OrderedOptions.new
    
    initializer "stale_if_slow.configure" do |app|
      settings = app.config.stale_if_slow
      StaleIfSlow.configure ({logger: Rails.logger}).merge(settings)
    end
  end
end