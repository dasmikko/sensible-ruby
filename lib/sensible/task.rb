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
      do_verify()

      # If check is not set, always run the task
      if @check == nil
        return false
      end

      # If there is no check, default to false, to force task to install every time
      system(@check, out: File::NULL)
      return $?.success?
    end  

    def do_install
      # TODO: Handle the show output property!

      if @install.include?("\n")
        puts "Is multi line install script, use a temp .sh file!"
        # TODO: Make a temporaty file in /tmp/sensible that contains the script, and run it, to make sure things run smoothly!
      end

      system(@install, out: File::NULL)
      return $?.success?        
    end

    def do_verify
      if !@install
        pastel = Pastel.new
        Logger.error("This is not valid task, #{pastel.bold("install")} property is missing!")
        exit(1)
        return false
      end

      return true
    end
  end
end
