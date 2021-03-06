module SmarterBundler
  module Shell
    def shell(command)
      puts '', "+ #{command}"
      output = []
      IO.popen("( #{command} ) 2>&1 < /dev/null") do |io|
        while line = io.gets
          puts line.chomp
          output << line.chomp
        end
        io.close
      end
      puts "Command returned status: #{$?.to_i} (#{$?.success? ? 'success' : 'fail'})"
      Struct.new(:status, :output).new($?, output)
    end

    def shell?(command)
      result = shell(command)
      result.status.success?
    end

  end
end
