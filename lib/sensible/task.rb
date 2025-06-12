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
      # If check is not set, always run the task
      if @check == nil
        return false
      end

      # If there is no check, default to false, to force task to install every time
      system(@check, out: File::NULL)
      return $?.success?
    end  

    def do_install
      system(@install, out: File::NULL)
      return $?.success?        
    end
  end
end
