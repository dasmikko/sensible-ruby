require_relative 'file'
require_relative 'log'
require 'tty-prompt'
require 'pastel'

module Sensible
  class Package
    attr_reader :sensible
    attr_reader :name
    attr_reader :check

    def initialize(packageHash, sensible)
      @name = packageHash['name']
      @sensible = sensible
    end


    # Check if the package is installed
    def do_check
      result = `rpm -q #{@name}`
      
      if result.include? 'is not installed'
        return false
      else 
        return true
      end           
    end
    
    # Install the package
    def do_install
      system("sudo dnf install -y #{@name}")
      return $?.success?
    end
  end
end