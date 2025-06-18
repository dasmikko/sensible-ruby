require_relative 'log'
require 'tty-prompt'
require 'pastel'

module Sensible
  class Package
    attr_reader :sensible
    attr_reader :name
    attr_reader :check
    attr_reader :install
    attr_reader :env

    def initialize(packageHash, sensible)
      @name = packageHash['name']
      @check = packageHash['check']
      @install = packageHash['install']
      @env = packageHash['env'] || []

      @sensible = sensible
    end

    # Check if the package is installed
    def do_check
      if @check
        result = `#{@check}`
        return $?.success?
      else 
        if sensible.package_check_command == nil
          Logger.error('No check property, and there is no global check command set.')
          exit(1)
        end

        check_command = "#{sensible.package_check_command}"
        check_command.sub!("$0", @name)
      
        system(check_command, out: File::NULL, err: File::NULL)
        return $?.success?   
      end         
    end
    
    # Install the package
    def do_install
      install_command = ""

      if @install == nil 
        install_command = "#{sensible.package_install_command}"
        install_command.sub!("$0", @name)
      else 
        if sensible.package_install_command == nil
          Logger.error('No install property, and there is no install check command set.')
          exit(1)
        end

        install_command = @install
      end 

      system(install_command, out: '/dev/null', err: File::NULL)
      return $?.success?   
    end 
  end
end