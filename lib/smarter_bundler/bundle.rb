module SmarterBundler

  class Bundle
    include SmarterBundler::Shell

    def run(bundle_args)
      puts "Smarter Bundler will recursively install your gems and output the successful bundler output. This may take a while."
      count = 0
      gemfile = SmarterBundler::Gemfile.new
      previous_failure = [ ]
      result = nil
      while count < 100
        result = call_bundle(bundle_args)
        failed_gem_and_version = parse_output(result)
        if failed_gem_and_version
          if previous_failure == failed_gem_and_version
            puts "Aborting: Stuck trying to install the same gem and version!"
            exit 1
          end
          previous_failure = failed_gem_and_version
          if install_failed_gem failed_gem_and_version
            puts "Retrying seems to have fixed the problem"
          elsif gemfile.restrict_gem_version failed_gem_and_version
            gemfile.save
            count += 1
          else
            puts "Aborting: Unable to install the same or earlier version of the gem"
            exit 2
          end
        else
          break
        end
      end
      puts "#{count} adjustments where made to the Gemfile"
      exit result ? result.status.to_i : 3
    end

    def call_bundle(bundle_args)
      shell "bundle #{bundle_args}"
    end

    def install_failed_gem(failed_gem_and_version)
      shell? "gem install '#{failed_gem_and_version[0]}' -v '#{failed_gem_and_version[1]}'"
    end

    def parse_output(result)
      result.output.each do |line|
        if line =~ /Make sure that `gem install (\S+) -v '(\S+)'`/
          return [$1, $2]
        end
      end
      nil
    end

  end

end
