require_relative 'log'
require_relative 'shell'
require 'tty-prompt'
require 'pastel'

module Sensible
  class Package
    attr_reader :sensible
    attr_reader :name
    attr_reader :distro

    def initialize(packageName, distro, sensible)
      @name = packageName
      @distro = distro
      @sensible = sensible
    end

    # Check if the package is installed
    def do_check
      check_command = nil

      case @distro
        when "rpm"
          check_command = "rpm -q #{name}"
        when "deb"
          check_command = "dpkg-query -W #{name}"
        when "aur"
          check_command = "pacman -Qi #{name}"
      end
      
      if check_command == nil
        Logger.error("Unknown check command")
        exit(1)
      end

      # Run the shell command
      shell = Shell.new(@sensible)
      return shell.run_command(check_command)        
    end
    
    # Install the package
    def do_install
      install_command = nil

      case @distro
      when "rpm"
        install_command = "sudo dnf install -y #{name}"
      when "deb"
        install_command = "sudo apt get install -y #{name}"
      when "aur"
        install_command = "pacman -Syu #{name}"
      end

      if install_command == nil
        Logger.error("Unknown install command")
        exit(1)
      end

      shell = Shell.new(@sensible)
      return shell.run_command(install_command)  
    end 
  end
end