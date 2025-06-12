require_relative 'package'

module Sensible
  class Task < Package
    attr_reader :file_name
    attr_reader :description
    attr_accessor :show_output

    def initialize(taskHash, file_name, sensible)
      super(taskHash, sensible)
      @file_name = file_name
      @description = taskHash['description']
      @show_output = taskHash['showOutput']
    end
    
    def do_check
      puts "To be implemented"
    end  

    def do_install
      puts "To be implemented"
    end
  end
end
