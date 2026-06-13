require_relative 'lib/apialerts/version'

Gem::Specification.new do |spec|
  spec.name        = 'apialerts'
  spec.version     = ApiAlerts::VERSION
  spec.authors     = ['API Alerts']
  spec.email       = ['support@apialerts.com']
  spec.summary     = 'Ruby client for the API Alerts notification platform'
  spec.description = 'Effortless project notifications. Send once, deliver everywhere.'
  spec.homepage    = 'https://apialerts.com'
  spec.license     = 'MIT'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/apialerts/apialerts-ruby',
    'bug_tracker_uri' => 'https://github.com/apialerts/apialerts-ruby/issues',
    'rubygems_mfa_required' => 'true'
  }

  spec.required_ruby_version = '>= 3.0.0'
  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md']

  spec.add_dependency 'net-http', '>= 0.3'

  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.65'
  spec.add_development_dependency 'webmock', '~> 3.23'
end
