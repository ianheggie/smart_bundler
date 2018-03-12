# SmarterBundler

Enhances bundler by adjusting Gemfile when correctable errors are found

It is primarily aimed at resolving ruby version conflicts where a gem now requires a later ruby version.

## Installation

Install it using:

    $ gem install smarter_bundler

Do not install it via Gemfile, as it needs to execute even if bundle can't install/update the gems in Gemfile

## Usage

Use smarter_bundle instead of the bundle command when installing or upgrading gems.

## Notes

The algorithm is simplistic - when an error of the form 
`Gem::RuntimeRequirementNotMetError: <gem_name> requires Ruby version`
is found, as well as
`An error occurred while installing <gem_name> (<gem_version>), and Bundler cannot continue`
Then it adjusts the Gemfile to require a version of that gem lower than the one that produced the error.

It will attempt upto 100 times to adjust the Gemfile before giving up.

Once the Gemfile has been adjusted, commit it into your source repository so that it does not need to be used again.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ianheggie/smarter_bundler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
