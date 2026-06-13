# API Alerts • Ruby Client

[![Gem](https://img.shields.io/gem/v/apialerts)](https://rubygems.org/gems/apialerts)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[RubyGems](https://rubygems.org/gems/apialerts) • [GitHub](https://github.com/apialerts/apialerts-ruby) • [API Alerts](https://apialerts.com)

Effortless project notifications. Send once, deliver everywhere.

## Installation

```ruby
gem 'apialerts'
```

Or install directly:

```bash
gem install apialerts
```

## Quick Start

```ruby
require 'apialerts'

ApiAlerts.configure('your-api-key')
ApiAlerts.send(ApiAlerts::Event.new(message: 'Deploy complete'))
```

## Usage

### Global singleton (recommended)

Call `configure` once at startup, then use `send` / `send_async` anywhere.

```ruby
require 'apialerts'

ApiAlerts.configure('your-api-key')

# Fire-and-forget - never raises
ApiAlerts.send(ApiAlerts::Event.new(message: 'Deploy complete'))

# Or get the result back
result = ApiAlerts.send_async(ApiAlerts::Event.new(message: 'Deploy complete'))
if result.success?
  puts "Sent to #{result.workspace} (#{result.channel})"
else
  puts "Error: #{result.error}"
end
```

### Event fields

Only `message` is required. All other fields are optional.

| Field     | Type     | Required | Description                      |
|-----------|----------|----------|----------------------------------|
| `message` | `String` | Yes      | Main notification message        |
| `channel` | `String` | No       | Target channel name              |
| `event`   | `String` | No       | Event key for routing            |
| `title`   | `String` | No       | Short title                      |
| `tags`    | `Array`  | No       | Categorisation tags              |
| `link`    | `String` | No       | URL associated with the event (deeplink + CTA) |
| `data`    | `Hash`   | No       | Arbitrary key-value metadata     |

```ruby
event = ApiAlerts::Event.new(
  message: 'Deploy complete',
  channel: 'releases',
  event:   'ci.deploy',
  title:   'Deployed',
  tags:    ['CI/CD', 'Ruby'],
  link:    'https://github.com/apialerts/apialerts-ruby/actions',
  data:    { version: '2.0.0' }
)
```

### Send to a different workspace

Pass an optional `api_key:` to override the configured key for a single call.

```ruby
ApiAlerts.send(event, api_key: 'other-workspace-key')

result = ApiAlerts.send_async(event, api_key: 'other-workspace-key')
```

### SendResult fields

`send_async` always returns a `SendResult` - it never raises.

| Field       | Type      | Description                                    |
|-------------|-----------|------------------------------------------------|
| `success?`  | `Boolean` | Whether the event was delivered successfully   |
| `workspace` | `String`  | Workspace the event was delivered to           |
| `channel`   | `String`  | Channel the event was delivered to             |
| `warnings`  | `Array`   | Non-fatal warnings returned by the API         |
| `error`     | `String`  | Error message when `success?` is false         |

## Links

- [Documentation](https://apialerts.com/docs)
- [Sign up](https://apialerts.com)
- [GitHub Issues](https://github.com/apialerts/apialerts-ruby/issues)
