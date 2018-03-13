# SmarterBundler

Enhances bundler by adjusting Gemfile when correctable errors are found.

It is primarily aimed at resolving ruby version conflicts where a gem now requires a later ruby version.

## Installation

Install it using:

    $ gem install smarter_bundler

Do not install it via Gemfile, as it needs to execute even if bundle can't install/update the gems in Gemfile

## Usage

Use smarter_bundle instead of the bundle command when installing or upgrading gems.

Smarter_bundle assumes that the gem bundler complains about is the one that needs to have its version restricted, as it can not determine if its that gem or the gem/s that require it that should be adjusted.

### Cleaning up afterwards

After smarter_bundle has updated the Gemfile, you should examine the changes, as some adjustments may be in order:
1. If a gem is not already referenced in the Gemfile, then look in Gemfile.lock for the gems that depend on it and place the new line in the same group as the related gems;
2. smarter_bundle does not backtrack and recheck earlier adjustments - this may result in a gem being restricted that is no longer needed because the gem that originally needed ended up being restricted to the point it no longer has so many prerequisites. In the Gemfile.lock you will see that the gem is not required by any other gems, nor was it a gem you directly need.
3. smarter_bundle does not know how to handle Gemfiles that are intended to be used with multiple ruby versions, so you will need to make a Gemfile that is intended for the ruby version you are checking it with and then incorporate the changes smarter_bundle makes back into the master Gemfile manually;

### Using in test or deploy scripts

If you are using it in an automated deploy (ie where you are not using Gemfile.lock),
then monitor the time the deploy takes, as 
the more fixes this program does, the longer it takes (since it reruns bundler to check the fixed Gemfile).
A reasonable limit would be four to ten times the time it normally takes to install.
Once you hit that limit, then check your install log and incorporate the fixes it has found into your Gemfile
source to remove the need for it to run bundler multiple times whilst it fixes the Gemfile.

## Notes

If the error indicates a ruby version conflict,
then it will lookup the gem on rubygems to find the earliest version with the same ruby spec
and update the Gemfile to specify a version prior to that. If the lookup of rubygems fails, then it will simply check the next earlier version.

Syntax errors will trigger smarter_bundle to try the immediately earlier version, without looking up rubygems, because a syntax error indicates the gemspec doesn't correctly specify the required ruby versions.

If the error was not from a ruby version conflict or syntax error, it will attempt to install the gem directly once more.

It will attempt to fix the Gemfile up to 100 times before giving up as long as each attempt is making progress.

Once the Gemfile has been adjusted, commit it into your source repository so that it does not need to be used again.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


### Testing in a VM

Use a vagrant virtual box for consistant results.

Install vagrant 1.9.7 or later and virtual_box or other local virtual machine providor.

Create a temp directory for throw away testing, and clone the gem into it

    mkdir -p ~/tmp
    cd ~/tmp
    git clone https://github.com/ianheggie/smarter_bundler.git ~/tmp/smarter_bundler

The Vagrantfile includes provisioning rules to install chruby (ruby version control),
ruby-build will also be installed and run to build various rubies under /opt/rubies.

Use <tt>vagrant ssh</tt> to connect to the virtual box and run tests.

Cd to the checked out smarter_bundler directory and then run the test as follows:

    cd ~/tmp/smarter_bundler

    vagrant up   # this will also run vagrant provision and take some time
                 # chruby and various ruby versions will be installed

    vagrant ssh

    cd /vagrant  # the current directory on your host is mounted here on the virtual machine

    chruby 2.2.2 # or some other ruby version (run chruby with no arguments to see the current list)

    bin/test

    exit        # from virtual machine when finished

The test script will run the smarter_bundle command on various rails Gemfiles (selected based on the current ruby version).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ianheggie/smarter_bundler.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
