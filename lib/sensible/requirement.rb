require_relative 'package'
require_relative 'parse'

module Sensible
  class Requirement
    attr_reader :sensible
    attr_reader :name
    attr_reader :check
    attr_reader :install
    attr_reader :env
    attr_reader :description
    attr_reader :packages
    # Pretty much the same as package right now

    def initialize(requirement_file_name, sensible)
      requirement_file_path = "#{sensible.sensible_folder}/#{sensible.requirements_folder}/#{requirement_file_name}.yml"

      # If requirement is not found, exit!
      if not File.exist?(requirement_file_path)
        pastel = Pastel.new
        Logger.error("Requirement: #{pastel.bold(requirement_file_name)} does not exist!")
        exit(1)
      end

      # Load the data
      requirement_data = YAML.load_file(requirement_file_path)

      @sensible = sensible
      @name = requirement_data["name"]
      @check = requirement_data["check"]
      @install = requirement_data["install"]
      @env = requirement_data["env"]
      @description = requirement_data["description"]

      # Parse packages
      @packages = Parse::parse_sensible_packages(requirement_data['packages'], sensible)
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

        system("#{temp_file_path}", out: File::NULL, err: File::NULL)
        return $?.success?  
      else
        system(@install, out: File::NULL, err: File::NULL)
        return $?.success?        
      end
    end
  end
end
