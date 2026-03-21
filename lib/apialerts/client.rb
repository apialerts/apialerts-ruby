require 'json'
require 'net/http'
require 'uri'

require_relative 'event'
require_relative 'result'
require_relative 'version'

module ApiAlerts
  API_URL = 'https://api.apialerts.com/event'

  # Instance-based API Alerts client.
  #
  # Use the module-level methods (ApiAlerts.configure / ApiAlerts.send_async)
  # for a convenient global singleton, or construct this class directly when
  # you need multiple clients or full lifecycle control.
  class Client
    def initialize(api_key, debug: false, http: nil)
      @api_key             = api_key
      @debug               = debug
      @integration         = INTEGRATION_NAME
      @integration_version = VERSION
      @base_url            = API_URL
      @http                = http
    end

    # Override the integration name, version, and base URL.
    #
    # Used by official integrations and in tests to redirect requests to a
    # mock server.
    def set_overrides(integration, version, base_url)
      @integration         = integration
      @integration_version = version
      @base_url            = base_url
      self
    end

    # Send an event — fire-and-forget. Never raises.
    # Critical errors (not configured, missing key, empty message) are always
    # logged to stderr. HTTP errors and success are only logged when debug is
    # enabled.
    def send(event)
      if @api_key.nil? || @api_key.empty?
        warn "x (apialerts.com) Error: api key is missing"
        return
      end
      if event.message.nil? || event.message.empty?
        warn "x (apialerts.com) Error: message is required"
        return
      end

      result = post(event)
      return unless @debug

      if result.success?
        warn "✓ (apialerts.com) Alert sent to #{result.workspace} (#{result.channel})"
        result.warnings.each { |w| warn "! (apialerts.com) Warning: #{w}" }
      else
        warn "x (apialerts.com) Error: #{result.error}"
      end
    end

    # Send an event and return a SendResult. Never raises.
    # Check result.success? to determine whether delivery succeeded.
    def send_async(event)
      if @api_key.nil? || @api_key.empty?
        return SendResult.new(success: false, error: 'api key is missing')
      end
      if event.message.nil? || event.message.empty?
        return SendResult.new(success: false, error: 'message is required')
      end

      post(event)
    end

    # Send an event using an explicit API key, bypassing the configured one.
    def send_with_key(api_key, event)
      if api_key.nil? || api_key.empty?
        return SendResult.new(success: false, error: 'api key is missing')
      end
      if event.message.nil? || event.message.empty?
        return SendResult.new(success: false, error: 'message is required')
      end

      post(event, api_key: api_key)
    end

    private

    def post(event, api_key: @api_key)
      uri     = URI.parse(@base_url)
      http    = @http || Net::HTTP.new(uri.host, uri.port).tap { |h| h.use_ssl = uri.scheme == 'https' }
      request = Net::HTTP::Post.new(uri.path.empty? ? '/' : uri.path)

      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type']  = 'application/json'
      request['X-Integration'] = @integration
      request['X-Version']     = @integration_version
      request.body             = JSON.generate(event.to_h)

      response = http.request(request)

      case response.code.to_i
      when 200
        body = JSON.parse(response.body)
        workspace = body['workspace']
        channel   = body['channel']
        unless workspace && channel
          return SendResult.new(success: false, error: 'invalid response from server')
        end

        warnings = body['warnings'] || []
        SendResult.new(success: true, workspace: workspace, channel: channel, warnings: warnings)
      when 400 then SendResult.new(success: false, error: 'bad request')
      when 401 then SendResult.new(success: false, error: 'unauthorized — check your api key')
      when 403 then SendResult.new(success: false, error: 'forbidden')
      when 429 then SendResult.new(success: false, error: 'rate limit exceeded')
      else          SendResult.new(success: false, error: "unexpected status: #{response.code.to_i}")
      end
    rescue JSON::ParserError
      SendResult.new(success: false, error: 'invalid response from server')
    rescue StandardError => e
      SendResult.new(success: false, error: e.message)
    end
  end
end
