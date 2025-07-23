require 'net/ssh'

module Sensible
  class Shell
    attr_reader :sensible

    def initialize(sensible)
      @sensible = sensible
    end

    def run_command(command, user = nil, show_output: false)
      show_output = @sensible.opts.verbose

      if (@sensible.opts.host != nil)
        # Run command on remote machine
        Net::SSH.start(@sensible.opts.host, 'root') do |ssh| 
                   
          final_command = nil

          if user != nil
            final_command = "sudo -iu #{user} bash -lc  \"#{command}\""
          else 
            final_command = command
          end

          out, err, code = exec_with_status(ssh, final_command)
          
          if @sensible.opts.verbose
            puts "STDOUT: #{out}"
            puts "STDERR: #{err}"
            puts "EXIT CODE: #{code}"
          end


          if code == 0
            return true
          else 
            return false
          end
        end
      else
        # Standard local shell command
        
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

    def exec_with_status(ssh, command)
      stdout = stderr = ""
      exit_code = nil

      ssh.open_channel do |ch|
        ch.exec(command) do |ch, success|
          raise "could not exec #{command}" unless success

          ch.on_data          { |c, d| stdout << d }
          ch.on_extended_data { |c, t, d| stderr << d }
          ch.on_request("exit-status") { |c, data| exit_code = data.read_long }
        end
      end
      ssh.loop
      [stdout, stderr, exit_code]
    end
  end
end