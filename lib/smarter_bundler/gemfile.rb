module SmarterBundler

  class Gemfile

    attr_reader :filename, :contents, :changed

    def initialize
      @filename = ENV['BUNDLE_GEMFILE'] || 'Gemfile'
      @contents = []
      File.open(@filename, 'r').each do |line|
        line.chomp
        @contents << line
      end
      @changed = false
    end

    def mentions? gem
      @contents.select { |line| line =~ /^\s*gem\s+['"]#{gem}['"]/ }.any?
    end

    def restrict_gem_version gem, version_limit
      return false unless version_limit.to_s =~ /\d\.\d/
      if ! mentions? gem
        @contents << "gem '#{gem}', '>=0'"
      end
      adjusted = false
      @contents.map! do |line|
        if line =~ /^(\s*gem\s+['"]#{gem}['"])(.*)$/
          gem_and_name = $1
          rest_of_line = $2
          versions = []
          if rest_of_line =~ /^\s*,\s*['"]([^'"]*)['"](.*)/
            versions = [$1]
            rest_of_line = $2
          elsif rest_of_line =~ /^\s*,\s*\[([^\]]*)\](.*)/
            rest_of_line = $2
            versions = $1.split(',').map { |s| s.sub(/^[\s'"]*/, '').sub(/[\s'"]*$/, '') }
          end
          #puts "Found #{gem_and_name} in Gemfile with version spec: #{versions.inspect} and other args: #{rest_of_line}"
          new_versions = versions.dup
          new_versions.delete_if { |s| s =~ /</ }
          new_versions << "< #{version_limit}"
          #puts "  Replacing with new version spec: #{new_versions.inspect}"
          if new_versions != versions
            @changed = true
            rest_of_line.sub!(/  # REQUIRED - Added by SmarterBundler.*/, '')
            rest_of_line << '  # REQUIRED - Added by SmarterBundler'
            line = "#{gem_and_name}, #{new_versions.inspect}#{rest_of_line}"
            puts "Changed Gemfile line to: #{line}"
            line
          else
            puts "Unable to change version for #{gem}"
            line
          end
        else
          line
        end
      end
      @changed
    end

    def save
      if @changed
        File.open("#{@filename}.new", 'w') do |file|
          file.puts *@contents
        end
        FileUtils.move "#{@filename}.new", @filename, :force => true
        @changed = false
        puts 'Currently restricted:', *(@contents.select { |line| line =~ /Added by SmarterBundler/ })
      end
    end

  end
end
