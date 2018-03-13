# SmarterBundler

Enhances bundler by adjusting Gemfile when correctable errors are found.

It is primarily aimed at resolving ruby version conflicts where a gem now requires a later ruby version.

## Installation

Install it using:

    $ gem install smarter_bundler

Do not install it via Gemfile, as it needs to execute even if bundle can't install/update the gems in Gemfile

## Usage

Use smarter_bundle instead of the bundle command when installing or upgrading gems.

If you are using it in an automated deploy, then monitor the time the deploy takes, as 
the more fixes this program does, the longer it takes (since it reruns bundler to check the fixed Gemfile).
A reasonable limit would be four to ten times the time it normally takes to install.
Once you hit that limit, then check your install log and incorporate the fixes it has found into your Gemfile
source to remove the need for it to run bundler multiple times whilst it fixes the Gemfile.

## Notes

If the error indicates a ruby version conflict, then it will lookup the gem on rubygems to find the earliest version with the same ruby spec
and update the Gemfile to specify a version prior to that. If the lookup of rubygems fails, then it will simply check the next earlier version.

If the error was not from a ruby version conflict, it will attempt to install the gem directly once more.

It will attempt to fix the Gemfile up to 100 times before giving up as long as each attempt is making progress.

Once the Gemfile has been adjusted, commit it into your source repository so that it does not need to be used again.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ianheggie/smarter_bundler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
