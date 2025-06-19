require_relative 'package'

module Sensible
  class Task
    attr_reader :sensible
    attr_reader :name
    attr_reader :packages
    attr_reader :check
    attr_reader :script
    attr_reader :require
    attr_reader :env
    attr_reader :file_name
    attr_reader :description
    attr_accessor :show_output

    def initialize(taskHash, file_name, sensible)
      @name = taskHash['name']
      @check = taskHash['check']
      @script = taskHash['script']
      @require = taskHash['require']
      @env = taskHash['env'] || []
      @file_name = file_name
      @description = taskHash['description']
      @show_output = taskHash['showOutput']
      
      @packages = []
      if taskHash['packages']
        taskHash['packages'].each do |distro, packages|
          packages.each do |packageName|
            @packages << Package.new(packageName, distro, sensible)
          end
        end
      end
    end

    def do_packages_check
      has_all_packages_install = true

      @packages.each do |package|
        package.name

        if !package.do_check
          has_all_packages_install = false
        end
      end
      
      return has_all_packages_install
    end
    
    def do_check
      do_verify()

      # If check is not set, always run the task
      if @check == nil
        return false
      end

      # If there is no check, default to false, to force task to script every time
      system(@check, out: File::NULL)
      return $?.success?
    end  

    def do_script
      # TODO: Handle the show output property!

      if @script.include?("\n")
        temp_path = "/tmp/sensible"
        temp_file_name = "script.sh"
        temp_file_path = "#{temp_path}/#{temp_file_name}"

        # Make sure we have the tmp folder created
        FileUtils.mkdir_p(temp_path)

        File.open(temp_file_path, "w") do |f| 
          f.puts "#!/usr/bin/env bash\n\n"
          f.write(@script)
        end

        # Make it executable
        File.chmod(0700, temp_file_path)

        system("#{temp_file_path}", out: File::NULL)
        return $?.success?  
      else
        system(@script, out: File::NULL)
        return $?.success?        
      end
    end

    def do_verify
      return true
    end
  end
end
