module SmarterBundler

  class Gemfile

    attr_reader :filename, :contents, :changed

    def initialize
      @filename = ENV['BUNDLE_GEMFILE'] || 'Gemfile'
      @contents = [ ]
      File.open(@filename, 'r').each do |line|
        line.chomp
        @contents << line
      end
      @changed = false
    end

    def restrict_gem_version gem, version_limit
      return false unless version_limit.to_s =~ /\d\.\d/
      if @contents.select{|line| line =~ /^\s*gem\s+['"]#{gem}['"]/}.empty?
        @contents << "gem '#{gem}', '>=0'"
      end
      adjusted = false
      @contents.map! do |line|
        if line =~ /^(\s*gem\s+['"]#{gem}['"])(\s*,\*['"]([^'"]*)['"])?(.*?)$/
          gem_and_name = $1
          rest_of_line = $4
          version = $3.to_s
          puts "Found #{gem_and_name} with version spec: #{version} and other args: #{rest_of_line}"
          new_version = version.sub(/<=?\s*[^,\s]+/, '').sub(/^\s*,\s*/, '').sub(/\s*,\s*$/, '') + (version == '' ? '' : ', ') + "< #{version_limit}"
          puts "  Calculated new_version spec: #{new_version}"
          if new_version != version
            @changed = true
            rest_of_line.sub!(/  # REQUIRED - Added by SmarterBundler.*/, '')
            rest_of_line << '  # REQUIRED - Added by SmarterBundler'
            line = "#{gem_and_name}, '#{new_version}'#{rest_of_line}"
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
      end
    end

  end
end
