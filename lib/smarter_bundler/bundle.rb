require 'fileutils'
require 'net/https'
require 'uri'
require 'yaml'

module SmarterBundler

  class Bundle
    include SmarterBundler::Shell

    KNOWN_ISSUES_187_192 = {
        'unicorn' => '5.0',
        'nokogiri' => '1.6.0',
        'jbuilder' => '2.0.0',
        'factory_girl' => '3.0',
        'factory_bot' => '3.0',
    }

    KNOWN_ISSUES_193_221 = {
    }

    KNOWN_ISSUES_222_22x = {
        'listen' => '3.1.2',
        'acts-as-taggable-on' => '5.0.0',
        'guard-rails' => '0.7.3',
        'jasmine' => '3.0.0',
        'ruby_dep' => '1.4.0',
    }


    def run(bundle_args)
      puts 'Smarter Bundler will recursively install your gems and output the successful bundler output. This may take a while.'
      count = 0
      gemfile = SmarterBundler::Gemfile.new
      previous_failure = []
      result = nil
      while count < 100
        result = call_bundle(bundle_args)
        failed_gem_and_version = parse_output(result)
        if failed_gem_and_version
          if previous_failure == failed_gem_and_version
            puts 'Aborting: Stuck trying to install the same gem and version!'
            exit 1
          end
          previous_failure = failed_gem_and_version
          gem, version = *failed_gem_and_version
          if !ruby_version_clash(result) && install_failed_gem(gem, version)
            puts 'Retrying seems to have fixed the problem'
          elsif gemfile.restrict_gem_version(gem, known_issues(gem))
            gemfile.save
            count += 1
          elsif ruby_version_clash(result) && gemfile.restrict_gem_version(gem, rubygems_earlier_version(gem, version))
            gemfile.save
            count += 1
          elsif ruby_version_clash(result) && gemfile.restrict_gem_version(gem, version)
            gemfile.save
            count += 1
          else
            puts 'Aborting: Unable to fix installation of gems'
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
      result.output.select { |l| l =~ /requires Ruby version/ }.any?
    end

    def known_issues(gem)
      if RUBY_VERSION <= '1.9.2'
        KNOWN_ISSUES_187_192[gem]
      elsif RUBY_VERSION <= '2.2.1'
        KNOWN_ISSUES_193_221[gem]
      elsif RUBY_VERSION <= '2.3'
        KNOWN_ISSUES_222_22x[gem]
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

    def rubygems_earlier_version(gem, version)
      @rubygems_cache = {}
      @platforms ||= begin
        if RUBY_PLATFORM =~ /linux/
          ['', 'ruby', 'mri']
        else
          [RUBY_PLATFORM]
        end
      end
      @rubygems_cache[gem] ||= begin
        url = "https://rubygems.org/api/v1/versions/#{gem}.yaml"

        uri = URI.parse(url)
        req = Net::HTTP::Get.new(uri.request_uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        response = http.request(req)

        text = response.body
        list = YAML.load(text)
        # puts "Request returned list: #{list.inspect}"
        list = list.select { |h| @platforms.include?(h['platform'].to_s) && !h['prerelease'] }.map do |h|
          h.reject do |k, v|
            %w{authors built_at created_at description downloads_count metadata summary rubygems_version licenses requirements sha}.include? k
          end
        end
        # puts "Trimmed prerelease list: #{list.inspect}"
        list
      rescue RuntimeError => ex
        puts "Ignoring exception: #{ex} - we will have to work it out the slow way"
        []
      end
      list = @rubygems_cache[gem]
      if list.size == 0
        puts "Unable to find version info at rubygems for #{gem}"
        return nil
      end
      current = list.select { |h| h['number'] == version }.first
      if current.nil?
        puts "Unable to find current version info at rubygems for #{gem}, version #{version}"
        return nil
      end
      puts "Found record for current version: #{current.inspect}"
      current_ruby_version = current['ruby_version']
      # puts "current ruby_version: #{current_ruby_version.inspect}"
      if current_ruby_version.nil?
        puts "Rubygems has nil ruby_version spec for #{gem} #{version} - unable to pick next version"
        return nil
      end
      found = false
      same_versions = list.select do |h|
        (h['ruby_version'] == current_ruby_version) && (h['number'] !~ /[a-z]/i)
      end
      next_version = same_versions.map { |h| h['number'] }.last
      puts "Selected next_version: #{next_version}"
      next_version
      # [
      #   {"authors":"Evan David Light",
      #     "built_at":"2011-08-08T04:00:00.000Z",
      #     "created_at":"2011-08-08T21:23:40.254Z",
      #     "description":"Behaviour Driven Development derived from Cucumber but as an internal DSL with methods for reuse",
      #     "downloads_count":3493,
      #     "metadata":{},
      #     "number":"0.7.1",
      #     "summary":"Test::Unit-based acceptance testing DSL",
      #     "platform":"ruby",
      #     "rubygems_version":"\u003e= 0",
      #     "ruby_version":null,
      #     "prerelease":false,
      #     "licenses":null,
      #     "requirements":null,
      #     "sha":"777c3a7ed83e44198b0a624976ec99822eb6f4a44bf1513eafbc7c13997cd86c"},
    end


  end

end
