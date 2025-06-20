module Sensible
  class Shell
    attr_reader :sensible

    def initialize(sensible)
      @sensible = sensible
    end

    def run_command(command, user = nil)
      # Look into using net-ssh: https://github.com/net-ssh/net-ssh

      show_output = false

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

        system("bash -s < #{temp_file_path}", out: (show_output ? $stdout : File::NULL), err: (show_output ? $stderr : File::NULL))
        return $?.success?
      else
        if user != nil
          system("sudo -u #{user} #{command}", out: (show_output ? $stdout : File::NULL), err: (show_output ? $stderr : File::NULL))
        else 
          system(command, out: (show_output ? $stdout : File::NULL), err: (show_output ? $stderr : File::NULL))
        end
        return $?.success?    
      end
    
    end
  end
end