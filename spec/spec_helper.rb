require 'ruby-debug'
require 'rspec'
require 'ostruct'
require 'stale_if_slow'

Dir['./spec/support/**/*.rb'].map {|f| require f}

RSpec.configure do |c|
  c.mock_with :rspec
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
  c.color_enabled = true
  c.formatter = :documentation
end