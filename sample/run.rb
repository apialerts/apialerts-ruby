require_relative '../lib/apialerts'

# Parse flags
build            = ARGV.include?('--build')
release          = ARGV.include?('--release')
publish          = ARGV.include?('--publish')
integration_tests = ARGV.include?('--integration-tests')

channel_idx = ARGV.index('--channel')
channel = channel_idx ? ARGV[channel_idx + 1] || 'testing' : 'testing'

api_key = ENV.fetch('APIALERTS_API_KEY', nil)
if api_key.nil? || api_key.empty?
  warn 'Error: APIALERTS_API_KEY environment variable is not set'
  exit 1
end

ApiAlerts.configure(api_key, debug: true)

link = 'https://github.com/apialerts/apialerts-ruby/actions'

if build
  result = ApiAlerts.send_async(ApiAlerts::Event.new(
    message: 'Ruby SDK - PR build success',
    channel: 'developer',
    event: 'ci.build',
    title: 'Build Passed',
    tags: ['CI/CD', 'Ruby', 'Build'],
    link: link,
    data: { integration: 'ruby' }
  ))
  unless result.success?
    warn "Error: #{result.error}"
    exit 1
  end
  puts "✓ Sent to #{result.workspace} (#{result.channel})"

elsif release
  result = ApiAlerts.send_async(ApiAlerts::Event.new(
    message: 'Ruby SDK - Build for publish success',
    channel: 'developer',
    event: 'ci.release',
    title: 'Release Build Passed',
    tags: ['CI/CD', 'Ruby', 'Build'],
    link: link,
    data: { integration: 'ruby' }
  ))
  unless result.success?
    warn "Error: #{result.error}"
    exit 1
  end
  puts "✓ Sent to #{result.workspace} (#{result.channel})"

elsif publish
  result = ApiAlerts.send_async(ApiAlerts::Event.new(
    message: 'Ruby SDK - RubyGems publish success',
    channel: 'releases',
    event: 'ci.publish',
    title: 'Published',
    tags: ['CI/CD', 'Ruby', 'Deploy'],
    link: link,
    data: { integration: 'ruby' }
  ))
  unless result.success?
    warn "Error: #{result.error}"
    exit 1
  end
  puts "✓ Sent to #{result.workspace} (#{result.channel})"

elsif integration_tests
  r1 = ApiAlerts.send_async(ApiAlerts::Event.new(message: 'Ruby SDK - minimal', channel: channel))
  unless r1.success?
    warn "Error (minimal): #{r1.error}"
    exit 1
  end
  puts "✓ sent to #{r1.workspace} (#{r1.channel})"

  r2 = ApiAlerts.send_async(ApiAlerts::Event.new(
    message: 'Ruby SDK - full',
    channel: channel,
    event: 'sdk.test',
    title: 'Integration Test',
    tags: ['CI/CD', 'Ruby'],
    link: link,
    data: { integration: 'ruby' }
  ))
  unless r2.success?
    warn "Error (full): #{r2.error}"
    exit 1
  end
  puts "✓ sent to #{r2.workspace} (#{r2.channel})"
else
  warn 'Error: pass --build, --release, --publish, or --integration-tests'
  exit 1
end
