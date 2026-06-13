module ApiAlerts
  # The result of an event delivery attempt.
  class SendResult
    attr_reader :success, :workspace, :channel, :warnings, :error

    def initialize(success:, workspace: nil, channel: nil, warnings: [], error: nil)
      @success   = success
      @workspace = workspace
      @channel   = channel
      @warnings  = warnings
      @error     = error
    end

    def success?
      @success
    end
  end
end
