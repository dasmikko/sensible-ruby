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
        # If check is not set, then infer that it's a system package
        result = `rpm -q #{@name}`
      
        if result.include? 'is not installed'
          return false
        else 
          return true
        end
      end
                 
    end
    
    # Install the package
    def do_install
      if @install 
        system(@install, out: File::NULL)
        return $?.success?        
      else
        system("sudo", "dnf", "install", "-y", @name, out: File::NULL, err: File::NULL)
        return $?.success?
      end
    end   
  end
end