module ApiAlerts
  # An event to send to the API Alerts platform.
  #
  # Only +message+ is required. All other fields are optional and omitted
  # from the JSON payload if nil — equivalent to Go's omitempty.
  #
  #   # Minimal
  #   event = ApiAlerts::Event.new(message: 'Deploy complete')
  #
  #   # Full
  #   event = ApiAlerts::Event.new(
  #     message: 'Deploy complete',
  #     channel: 'releases',
  #     event:   'ci.deploy',
  #     title:   'Deployed',
  #     tags:    ['CI/CD', 'Ruby'],
  #     link:    'https://github.com/apialerts/apialerts-ruby/actions',
  #     data:    { version: '2.0.0' }
  #   )
  class Event
    attr_reader :message, :channel, :event, :title, :tags, :link, :data

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
