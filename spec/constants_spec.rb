require 'spec_helper'

# Pins the literal contract values so an accidental edit (wrong integration
# name, a v2 bump, a changed endpoint or timeout) fails CI loudly.
RSpec.describe 'contract constants' do
  it 'identifies the integration as "ruby"' do
    expect(ApiAlerts::INTEGRATION_NAME).to eq('ruby')
  end

  it 'points at the production event endpoint' do
    expect(ApiAlerts::API_URL).to eq('https://api.apialerts.com/event')
  end

  it 'uses a 30 second timeout' do
    expect(ApiAlerts::TIMEOUT_SECONDS).to eq(30)
  end

  it 'stays on major version 1 (guards against an accidental v2 bump)' do
    # Accepts 1.x.y and RubyGems pre-release forms like 1.0.0.alpha.1.
    expect(ApiAlerts::VERSION).to match(/\A1\.\d+\.\d+(\.[A-Za-z]+(\.\d+)?)?\z/)
  end
end
