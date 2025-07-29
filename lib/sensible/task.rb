require_relative 'package'
require_relative 'shell'
require 'fileutils'
require 'shellwords'

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
    attr_reader :copy

    def initialize(taskHash, file_name, user = nil, sensible)
      @name = taskHash['name']
      @check = taskHash['check']
      @script = taskHash['script']
      @require = taskHash['require']
      @env = taskHash['env'] || []
      @file_name = file_name
      @description = taskHash['description']
      @show_output = taskHash['showOutput']
      @copy = taskHash['copy']
      
      # If task is initalized with user, force use of that
      if user != nil
        @user = user
      end
      
      # Always use the user from the task
      if taskHash['user'] != nil
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
      # Always return false to force copy
      if @copy != nil
        return false
      end

      # If check is not set, always run the task
      if @check == nil
        return false
      end

      # If there is no check, default to false, to force task to script every time
      shell = Shell.new(@sensible)
      return shell.run_command(@check, @user)
    end

    def do_script
      if @copy != nil
        origin = File.expand_path(@copy['origin'])
        destination = @copy['dest']
        destination_expanded = File.expand_path(@copy['dest'])
        
        puts destination

        commmand = nil
        
        if @sensible.opts.host 
          if @user 

            command = "rsync -avu --delete #{Shellwords.escape(origin)} root@#{@sensible.opts.host}:#{Shellwords.escape(destination.sub('~', "/home/#{user}"))}"
          else 
            command = "rsync -avu --delete #{Shellwords.escape(origin)} root@#{@sensible.opts.host}:#{Shellwords.escape(destination)}"
          end
          
        else 
          command = "rsync -avu --delete #{Shellwords.escape(origin)} #{Shellwords.escape(destination_expanded)}"
        end
        
        if @sensible.opts.verbose 
          system(command)
        else 
          system(command, out: File::NULL, err: File::NULL)
        end
        
        return $?.success?   
      end


      # TODO: Handle the show output property!
      shell = Shell.new(@sensible)
      return shell.run_command(@script, @user)         
    end

    def do_verify
      return true
    end


    def check_exists(path)
      is_folder = path.end_with?('/')
      expanded_path = File.expand_path(path)

      if is_folder == true
        return Dir.exist?(expanded_path)
      else
        return File.exist?(expanded_path)
      end

      # Handle remote
    end
  end
end
