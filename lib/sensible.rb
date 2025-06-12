# frozen_string_literal: true
require 'yaml'
require_relative "sensible/version"
require_relative "sensible/package"
require_relative "sensible/log"
require_relative "sensible/parse"

module Sensible
  class Error < StandardError; end

  class Sensible
    attr_reader :opts
    attr_reader :args

    attr_reader :packages
    attr_reader :requirements
    attr_reader :tasks
    
    attr_reader :sensible_folder
    attr_reader :tasks_folder


    def initialize(sensibleFileName, opts, args)
      @opts = opts
      @args = args

      @sensible_folder = '.sensible'
      @tasks_folder = 'tasks'

      file_name = opts.file || sensibleFileName
      unless File.exist?(file_name)
          STDERR.puts "❌ Error: Required file not found: #{file_name}"
          exit(1)
      end

      # Load the Sensile file
      sensible_file_data = YAML.load_file(file_name)

      # Parse packages
      if sensible_file_data['packages'] 
        @packages = Parse.parse_sensible_packages(sensible_file_data['packages'], self)
      end

      # Parse tasks
      tasks_path = "#{@sensible_folder}/#{tasks_folder}"
      task_files = Dir.children(tasks_path)

      @tasks = []
      for task_file in task_files
        @tasks << Task.new(YAML.load_file("#{tasks_path}/#{task_file}"), task_file, self)
      end
    end


    # Run all the checks for packages and requirements
    def check
      Logger.log("Checking for installed packages...")
      
      for pkg in @packages
        # Do an environment test
        if @opts.env
          # If package env is not define, we expect it should always be installed regardless of environment
          # If user has defined an environment, skip if the set environment isn't in the package enviroment list 
          next if pkg.env.any? && !pkg.env.include?(@opts.env)
        else
          # If env contains anything, when env is not defined in opts, skip it, as this is not the correct env
          next if pkg.env.any?
        end

        if pkg.do_check
          Logger.success("#{pkg.name} is installed", 2)
        else
          Logger.danger("#{pkg.name} was NOT installed", 2)
        end
      end    
    end

    def install
      Logger.log("Installing packages...")

      # Prewarm sudo, to prevent asking too much
      system('sudo -v')

      for pkg in @packages
        # Do an environment test
        if @opts.env
          # If package env is not define, we expect it should always be installed regardless of environment
          # If user has defined an environment, skip if the set environment isn't in the package enviroment list 
          next if pkg.env.any? && !pkg.env.include?(@opts.env)
        else
          # If env contains anything, when env is not defined in opts, skip it, as this is not the correct env
          next if pkg.env.any?
        end

        if pkg.do_check
          Logger.success("#{pkg.name} is installed", 2)
        else
          Logger.info("Installing: #{pkg.name}\r", 2, use_print: true)
          if pkg.do_install
            Logger.success("#{pkg.name} was installed", 2)
            $stdout.flush
          else
            Logger.danger("#{pkg.name} was not installed", 2)
            $stdout.flush
          end
        end
      end  
    end

    def init
      puts "  initializing"
    end

    def task(env, file, dir, task)
      puts "  executing #{task}"
    end

    def task_run(task_name)
      task = @tasks.detect {|e| e.file_name == "#{task_name}.yml"}

      # If task is not found, exit!
      if task == nil
         Logger.error("#{task_name}: Does not exist!")
         exit(1)
      end
       puts "Running task: #{task_name}"
      
      # Check if we need to rerun the task
      if !task.do_check
        task.do_install
      else
        puts "Task check is already met"
      end
    end

    def task_list
      puts "Here is available tasks inside #{@sensible_folder}/#{tasks_folder}" if @opts.verbose
      pastel = Pastel.new
      for task in @tasks
        Logger.log("#{pastel.blue.bold(task.file_name)}: #{task.name}")
        pp task
      end
    end
  end
end
