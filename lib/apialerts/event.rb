module ApiAlerts
  # An event to send to the API Alerts platform.
  #
  # Only +message+ is required. All other fields are optional and omitted
  # from the JSON payload when nil.
  #
  #   # Minimal
  #   event = ApiAlerts::Event.new(message: 'Deploy complete')
  #
  #   # Full
  #   event = ApiAlerts::Event.new(
  #     message: 'Deploy complete',
  #     channel: 'releases',
  #     event:   'ci.deploy.success',
  #     title:   'Deployed',
  #     tags:    ['CI/CD', 'Ruby'],
  #     link:    'https://github.com/apialerts/apialerts-ruby/actions',
  #     data:    { commit: 'a1b2c3d' }
  #   )
  class Event
    # Human-readable notification text. Required. Appears on the push lock screen.
    attr_reader :message
    # Workspace channel the push fires on. Defaults to the workspace default when omitted.
    attr_reader :channel
    # What kind of thing happened. Optional but recommended. Dotted notation
    # ("ci.deploy.success", "payment.failed") so routing rules can match with
    # wildcards ("ci.*", "*.failed").
    attr_reader :event
    # Short headline some destinations render separately from the body.
    attr_reader :title
    # Categorisation tags for filtering and search.
    attr_reader :tags
    # URL attached to the notification. Tapping the push opens it.
    attr_reader :link
    # Arbitrary key-value metadata. Available to non-push destinations for templating.
    attr_reader :data

    def initialize(message:, channel: nil, event: nil, title: nil, tags: nil, link: nil, data: nil)
      @message = message
      @channel = channel
      @event   = event
      @title   = title
      @tags    = tags
      @link    = link
      @data    = data
    end

    def to_h
      h = { message: message }
      h[:channel] = channel unless channel.nil?
      h[:event]   = event   unless event.nil?
      h[:title]   = title   unless title.nil?
      h[:tags]    = tags    unless tags.nil?
      h[:link]    = link    unless link.nil?
      h[:data]    = data    unless data.nil?
      h
    end
  end
end
