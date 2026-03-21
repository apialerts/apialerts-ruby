require_relative 'apialerts/version'
require_relative 'apialerts/event'
require_relative 'apialerts/result'
require_relative 'apialerts/client'

# Global singleton facade for the API Alerts client.
#
#   ApiAlerts.configure('your-api-key')
#   ApiAlerts.send(ApiAlerts::Event.new(message: 'Deploy complete'))
module ApiAlerts
  class << self
    # Initialise the global client. Subsequent calls are no-ops.
    def configure(api_key, debug: false, http: nil)
      @client ||= Client.new(api_key, debug: debug, http: http)
    end

    # Override the integration name, version, and base URL on the global client.
    # No-op if configure has not been called yet.
    def set_overrides(integration, version, base_url)
      @client&.set_overrides(integration, version, base_url)
    end

    # Send an event — fire-and-forget. Never raises.
    # Silently does nothing if the global client has not been initialised.
    def send(event)
      unless @client
        warn "x (apialerts.com) Error: client not configured"
        return
      end
      @client.send(event)
    end

    # Send an event and return a SendResult. Never raises.
    # Returns SendResult with success: false if not configured.
    def send_async(event)
      unless @client
        return SendResult.new(success: false, error: 'client not configured')
      end
      @client.send_async(event)
    end

    # @private — for use in tests only
    def reset!
      @client = nil
    end
  end
end
