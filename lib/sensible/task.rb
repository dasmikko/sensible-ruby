require_relative 'package'
require_relative 'shell'

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
    attr_reader :user
    attr_reader :description
    attr_accessor :show_output

    def initialize(taskHash, file_name, user = nil, sensible)
      @name = taskHash['name']
      @check = taskHash['check']
      @script = taskHash['script']
      @require = taskHash['require']
      @env = taskHash['env'] || []
      @file_name = file_name
      @description = taskHash['description']
      @show_output = taskHash['showOutput']
      
      # If task is initalized with user, force use of that
      if user != nil
        @user = user
      else
        @user = taskHash['user']
      end

      @sensible = sensible
      
      @packages = []
      if taskHash['packages']
        taskHash['packages'].each do |distro, packages|
          packages.each do |packageName|
            @packages << Package.new(packageName, distro, sensible)
          end
        end
      end
    end

    # Check if the packages in this task is installed
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

    # Install the packages in this task
    def do_packages_install
      has_all_packages_install = true

      @packages.each do |package|
        if !package.do_install
          has_all_packages_install = false
        end
      end

      return has_all_packages_install
    end
    
    def do_check
      if @user
        puts "Check as user: " + @user
      end

      # If check is not set, always run the task
      if @check == nil
        return false
      end

      # If there is no check, default to false, to force task to script every time
      shell = Shell.new(@sensible)
      return shell.run_command(@check)
    end

    def do_script
      # TODO: Handle the show output property!
      shell = Shell.new(@sensible)
      return shell.run_command(@script)         
    end

    def do_verify
      return true
    end
  end
end
