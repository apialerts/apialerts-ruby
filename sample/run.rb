require_relative '../lib/apialerts'

# Parse flags
build   = ARGV.include?('--build')
release = ARGV.include?('--release')
publish = ARGV.include?('--publish')

api_key = ENV['APIALERTS_API_KEY']
if api_key.nil? || api_key.empty?
  warn 'APIALERTS_API_KEY not set'
  exit 1
end

ApiAlerts.configure(api_key, debug: true)

# Minimal send — message only
result = ApiAlerts.send_async(ApiAlerts::Event.new(message: 'Ruby SDK - minimal'))
unless result.success?
  warn "Error (minimal): #{result.error}"
  exit 1
end
puts "Sent to #{result.workspace} (#{result.channel})"

# Full send — all fields
result = ApiAlerts.send_async(ApiAlerts::Event.new(
  message: 'Ruby SDK - full',
  channel: 'developer',
  event:   'sdk.test',
  title:   'Integration Test',
  tags:    ['CI/CD', 'Ruby'],
  link:    'https://github.com/apialerts/apialerts-ruby/actions',
  data:    { version: '2.0.0', build: build, release: release, publish: publish }
))
unless result.success?
  warn "Error (full): #{result.error}"
  exit 1
end
puts "Sent to #{result.workspace} (#{result.channel})"
