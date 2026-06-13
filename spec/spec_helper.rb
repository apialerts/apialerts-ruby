require 'webmock/rspec'
require 'apialerts'

RSpec.configure do |config|
  config.after(:each) { ApiAlerts.reset! }
end
