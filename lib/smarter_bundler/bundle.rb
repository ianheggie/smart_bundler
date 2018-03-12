module SmarterBundler

  class Bundle
    include SmarterBundler::Shell

    def run(bundle_args)
      puts "Smarter Bundler will recursively install your gems and output the successful bundler output. This may take a while."
      count = 0
      gemfile = SmarterBundler::Gemfile.new
      while count < 100
        result = call_bundle(bundle_args)
        failed_gem_and_version = parse_output(result)
        if failed_gem_and_version
          if install_failed_gem failed_gem_and_version
            puts "retrying seems to have fixed the problem"
          elsif gemfile.restrict_gem_version failed_gem_and_version
            gemfile.save
            count += 1
          else
            puts "Unable fix the problem"
            break
          end
        else
          break
        end
      end
      puts "#{count} adjustments where made to the Gemfile"
    end

    def call_bundle(bundle_args)
      shell "bundle #{bundle_args}"
    end

    def install_failed_gem(failed_gem_and_version)
      shell? "gem install '#{failed_gem_and_version[0]}' -v '#{failed_gem_and_version[1]}'"
    end

    def parse_output(result)
      if result.output.include?("Make sure that `")
        cmd = result.output.split("Make sure that `")[1].split("`")[0]
      else
        nil
      end
    end

  end

end
