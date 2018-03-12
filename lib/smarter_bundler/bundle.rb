require 'fileutils'

module SmarterBundler

  class Bundle
    include SmarterBundler::Shell

    KNOWN_ISSUES_192 = {
       'unicorn' => '5.0'
     }

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
          gem, version = *failed_gem_and_version
          if install_failed_gem gem, version
            puts "Retrying seems to have fixed the problem"
          elsif gemfile.restrict_gem_version(gem, known_issues(gem))
            gemfile.save
            count += 1
          elsif ruby_version_clash(result) && gemfile.restrict_gem_version(gem, version)
            gemfile.save
            count += 1
          else
            puts "Aborting: Unable to fix installation of gems"
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

    def install_failed_gem(gem, version)
      shell? "gem install '#{gem}' -v '#{version}'"
    end

    def ruby_version_clash(result)
      result.output.select{|l| l =~ /requires Ruby version/}.any?
    end

    def known_issues(gem)
      if RUBY_VERSION < '1.9.3'
        KNOWN_ISSUES_192[gem]
      else
        nil
      end
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
