module SmarterBundler
  module Shell
    def shell(command)
      puts '',"+ #{command}"
      output = [ ]
      IO.popen("#{command} 2>&1") do |io|
        while line = io.gets
          puts line.chomp
          output << line.chomp
        end
        io.close
      end
      Struct.new(:status, :output).new($?, output)
    end
  
    def shell?(command)
      result = shell(command)
      result.status.success?
    end
  end
end
