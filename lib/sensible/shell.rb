module Sensible
  class Shell
    attr_reader :sensible

    def initialize(sensible)
      @sensible = sensible
    end

    def run_command(command, user = nil)
      # Look into using net-ssh: https://github.com/net-ssh/net-ssh

      show_output = @sensible.opts.verbose

      # If command contains new lines, use a temporary file
      if command.include?("\n")
        system("bash", "-c", command, out: (show_output ? $stdout : File::NULL), err: (show_output ? $stderr : File::NULL))
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