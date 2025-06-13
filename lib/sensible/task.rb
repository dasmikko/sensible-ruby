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
        temp_path = "/tmp/sensible"
        temp_file_name = "install.sh"
        temp_file_path = "#{temp_path}/#{temp_file_name}"

        # Make sure we have the tmp folder created
        FileUtils.mkdir_p(temp_path)

        File.open(temp_file_path, "w") do |f| 
          f.puts "#!/usr/bin/env bash\n\n"
          f.write(@install)
        end

        # Make it executable
        File.chmod(0700, temp_file_path)

        system("#{temp_file_path}", out: File::NULL)
        return $?.success?  
      else
        system(@install, out: File::NULL)
        return $?.success?        
      end
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
