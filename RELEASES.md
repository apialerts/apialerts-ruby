# Release Process

## Files to update

1. `lib/apialerts/version.rb` - update `VERSION` constant

## Alpha release

Use this to test before publishing to `latest`.

1. Set version to `x.y.z.alpha.N` (e.g. `1.0.0.alpha.1`) in `version.rb`
2. Create a GitHub release tagged `x.y.z.alpha.N`, **check "Set as pre-release"**
3. GitHub Actions runs the `publish-alpha` job and pushes to RubyGems
4. Install with `gem install apialerts --pre` - does **not** affect `gem install apialerts`

## Full release

1. Set version to `x.y.z` in `version.rb`
2. Create a GitHub release tagged `x.y.z`, **uncheck "Set as pre-release"**
3. GitHub Actions runs the `publish-release` job and pushes to RubyGems
4. Becomes the new stable release - `gem install apialerts` picks it up

## Checking RubyGems versions

```bash
gem list --remote apialerts --all
```
