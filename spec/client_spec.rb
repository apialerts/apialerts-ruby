require 'spec_helper'

RSpec.describe ApiAlerts::Client do
  let(:api_url)    { 'https://api.apialerts.com/event' }
  let(:api_key)    { 'test-api-key' }
  let(:client)     { described_class.new(api_key) }

  def stub_api(status:, body: nil)
    body ||= { workspace: 'My Workspace', channel: 'general', warnings: [] }.to_json
    stub_request(:post, api_url).to_return(status: status, body: body,
      headers: { 'Content-Type' => 'application/json' })
  end

  # ── Validation ────────────────────────────────────────────────────────────

  describe 'validation' do
    it 'returns failure result when api key is empty' do
      result = described_class.new('').send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be false
      expect(result.error).to eq('api key is missing')
    end

    it 'returns failure result when message is empty' do
      result = client.send_async(ApiAlerts::Event.new(message: ''))
      expect(result.success?).to be false
      expect(result.error).to eq('message is required')
    end
  end

  # ── HTTP status codes ─────────────────────────────────────────────────────

  describe 'HTTP status codes' do
    it '200 returns a successful SendResult' do
      stub_api(status: 200, body: { workspace: 'W', channel: 'C', warnings: [] }.to_json)
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be true
      expect(result.workspace).to eq('W')
      expect(result.channel).to eq('C')
      expect(result.warnings).to be_empty
    end

    it '200 with warnings populates warnings' do
      stub_api(status: 200, body: { workspace: 'W', channel: 'C', warnings: ['deprecated'] }.to_json)
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be true
      expect(result.warnings).to eq(['deprecated'])
    end

    it '400 returns failure with bad request error' do
      stub_api(status: 400)
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be false
      expect(result.error).to eq('bad request')
    end

    it '401 returns failure with unauthorized error' do
      stub_api(status: 401)
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be false
      expect(result.error).to eq('unauthorized, check your api key')
    end

    it '403 returns failure with forbidden error' do
      stub_api(status: 403)
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be false
      expect(result.error).to eq('forbidden')
    end

    it '429 returns failure with rate limit error' do
      stub_api(status: 429)
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be false
      expect(result.error).to eq('rate limit exceeded')
    end

    it '500 returns failure with unexpected status error' do
      stub_api(status: 500)
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be false
      expect(result.error).to eq('unexpected status: 500')
    end

    it 'invalid JSON returns failure with invalid response error' do
      stub_api(status: 200, body: 'not json')
      result = client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(result.success?).to be false
      expect(result.error).to eq('invalid response from server')
    end
  end

  # ── Request headers ───────────────────────────────────────────────────────

  describe 'request headers' do
    it 'sends Authorization header' do
      stub = stub_request(:post, api_url)
             .with(headers: { 'Authorization' => 'Bearer test-api-key' })
             .to_return(status: 200, body: { workspace: 'W', channel: 'C', warnings: [] }.to_json)
      client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(stub).to have_been_requested
    end

    it 'sends X-Integration and X-Version headers' do
      stub = stub_request(:post, api_url)
             .with(headers: { 'X-Integration' => 'ruby', 'X-Version' => ApiAlerts::VERSION })
             .to_return(status: 200, body: { workspace: 'W', channel: 'C', warnings: [] }.to_json)
      client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(stub).to have_been_requested
    end

    it 'set_overrides changes integration headers' do
      mock_url = 'http://localhost:4567/event'
      client.set_overrides('github-actions', '1.0.0', mock_url)
      stub = stub_request(:post, mock_url)
             .with(headers: { 'X-Integration' => 'github-actions', 'X-Version' => '1.0.0' })
             .to_return(status: 200, body: { workspace: 'W', channel: 'C', warnings: [] }.to_json)
      client.send_async(ApiAlerts::Event.new(message: 'test'))
      expect(stub).to have_been_requested
    end

    it 'api_key: override uses the provided key' do
      stub = stub_request(:post, api_url)
             .with(headers: { 'Authorization' => 'Bearer override-key' })
             .to_return(status: 200, body: { workspace: 'W', channel: 'C', warnings: [] }.to_json)
      client.send(ApiAlerts::Event.new(message: 'test'), api_key: 'override-key')
      expect(stub).to have_been_requested
    end
  end

  # ── Payload serialization ─────────────────────────────────────────────────

  describe 'payload' do
    it 'sends all fields' do
      payload = {
        message: 'Full payload',
        channel: 'developer',
        event: 'ci.deploy',
        title: 'Deployed',
        tags: ['CI/CD', 'Ruby'],
        link: 'https://github.com',
        data: { version: '2.0.0' }
      }
      stub = stub_request(:post, api_url)
             .with(body: payload)
             .to_return(status: 200, body: { workspace: 'W', channel: 'C', warnings: [] }.to_json)
      client.send_async(ApiAlerts::Event.new(**payload))
      expect(stub).to have_been_requested
    end

    it 'omits nil fields from payload' do
      stub_api(status: 200)
      client.send_async(ApiAlerts::Event.new(message: 'minimal'))
      expect(WebMock).to(have_requested(:post, api_url).with do |req|
        body = JSON.parse(req.body)
        !body.key?('channel') && !body.key?('event') && !body.key?('title') &&
          !body.key?('tags') && !body.key?('link') && !body.key?('data')
      end)
    end
  end

  # ── Fire-and-forget ───────────────────────────────────────────────────────

  describe '#send (fire-and-forget)' do
    it 'does not raise on error' do
      stub_api(status: 401)
      expect { client.send(ApiAlerts::Event.new(message: 'test')) }.not_to raise_error
    end

    it 'does not raise when message is empty' do
      expect { client.send(ApiAlerts::Event.new(message: '')) }.not_to raise_error
    end
  end
end

# ── Global singleton ──────────────────────────────────────────────────────────

RSpec.describe ApiAlerts do
  let(:api_url) { 'https://api.apialerts.com/event' }

  def stub_success
    stub_request(:post, api_url)
      .to_return(status: 200, body: { workspace: 'W', channel: 'C', warnings: [] }.to_json,
        headers: { 'Content-Type' => 'application/json' })
  end

  it 'returns failure result before configure' do
    result = described_class.send_async(ApiAlerts::Event.new(message: 'test'))
    expect(result.success?).to be false
    expect(result.error).to eq('client not configured')
  end

  it 'configure initialises the client' do
    stub_success
    described_class.configure('key')
    result = described_class.send_async(ApiAlerts::Event.new(message: 'test'))
    expect(result.success?).to be true
    expect(result.workspace).to eq('W')
  end

  it 'configure is idempotent - second call is a no-op' do
    stub_success
    described_class.configure('first-key')
    described_class.configure('second-key')
    described_class.send_async(ApiAlerts::Event.new(message: 'test'))
    expect(WebMock).to have_requested(:post, api_url)
      .with(headers: { 'Authorization' => 'Bearer first-key' })
  end

  it 'send is a no-op before configure' do
    expect { described_class.send(ApiAlerts::Event.new(message: 'test')) }.not_to raise_error
  end
end
