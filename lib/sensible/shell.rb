module Sensible
  class Shell
    attr_reader :sensible

    def initialize(sensible)
      @sensible = sensible
    end

    def run_command(command)
      # If command contains new lines, use a temporary file
      if command.include?("\n")
        temp_path = "/tmp/sensible"
        temp_file_name = "script.sh"
        temp_file_path = "#{temp_path}/#{temp_file_name}"

        # Make sure we have the tmp folder created
        FileUtils.mkdir_p(temp_path)

        File.open(temp_file_path, "w") do |f| 
          f.puts "#!/usr/bin/env bash\n\n"
          f.write(command)
        end

        # Make it executable
        File.chmod(0700, temp_file_path)

        if @sensible.opts.host
          system("ssh #{sensible.opts.host} 'bash -s' < #{temp_file_path}", out: File::NULL, err: File::NULL)
          return $?.success?
        else
          system("bash -s < #{temp_file_path}", out: File::NULL, err: File::NULL)
          return $?.success?
        end
      else
        if @sensible.opts.host
          system("ssh #{sensible.opts.host} -t '#{command}'", out: File::NULL, err: File::NULL)
          return $?.success?
        else
         system(command, out: File::NULL, err: File::NULL)
         return $?.success?   
        end    
      end
      
      
      
      
    end
  end
end