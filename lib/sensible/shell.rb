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
          out, err, code = exec_user_with_status(ssh, command, as_user: user)
          
          if @sensible.opts.verbose
            puts "STDOUT: #{out}"
            puts "STDERR: #{err}"
            puts "EXIT CODE: #{code}"
          end
          
          # Show a warning if the user does not exist!
          if err.include?("does not exist or the user entry does not contain all the required fields")
            Logger.error("User: '#{user}' does not exist!")
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

    def exec_user_with_status(ssh, command, as_user: nil)
      stdout    = ''
      stderr    = ''
      exit_code = nil

      ssh.open_channel do |ch|

        if as_user 
          ch.exec("su - #{as_user}") do |ch_exec, success|
            raise "could not exec sudo" unless success
            ch.send_data("#{command}\n")

            ch.on_data          { |_, data| stdout << data }
            ch.on_extended_data { |_, _, data| stderr << data }
            ch.on_request("exit-status") { |_, data| exit_code = data.read_long }

            # when done:
            ch.send_data("exit\n")
          end
        else
          ch.exec(command) do |ch_exec, success|
            raise "Could not exec #{cmd}" unless success

            ch.on_data          { |_, data| stdout << data }
            ch.on_extended_data { |_, _, data| stderr << data }
            ch.on_request("exit-status") { |_, data| exit_code = data.read_long }
          end
        end
      end

      ssh.loop
      [stdout, stderr, exit_code]
    end

  end
end