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

    attr_reader :preTasks
    attr_reader :packages
    attr_reader :requirements
    attr_reader :postTasks
    
    attr_reader :sensible_folder
    attr_reader :tasks_folder


    def initialize(sensibleFileName, opts, args)
      @opts = opts
      @args = args

      @sensible_folder = '.sensible'
      @tasks_folder = 'tasks'

      file_name = opts.file || sensibleFileName
      unless File.exist?(file_name)
          Logger.error("Required file not found: #{file_name}")
          exit(1)
      end

      # Load the Sensile file
      sensible_file_data = YAML.load_file(file_name)

      # Parse packages
      if sensible_file_data['packages'] 
        @packages = Parse.parse_sensible_packages(sensible_file_data['packages'], self)
      end

      # Parse packages
      if sensible_file_data['requirements'] 
        @requirements = Parse.parse_sensible_requirements(sensible_file_data['requirements'], self)
      end

      if (sensible_file_data['preTasks'])
        pp sensible_file_data['preTasks']
        @preTasks = sensible_file_data['preTasks']
      end

      if (sensible_file_data['postTasks'])
        pp sensible_file_data['postTasks']
        @postTasks = sensible_file_data['postTasks']
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
          Logger.success("#{pkg.name} is installed")
        else
          Logger.danger("#{pkg.name} was NOT installed")
        end
      end    
      
      if @requirements != nil
        Logger.log("\nChecking if requirements are met...")

        for requirement in @requirements
          # Do an environment test
          if @opts.env
            # If package env is not define, we expect it should always be installed regardless of environment
            # If user has defined an environment, skip if the set environment isn't in the package enviroment list 
            next if requirement.env.any? && !requirement.env.include?(@opts.env)
          else
            # If env contains anything, when env is not defined in opts, skip it, as this is not the correct env
            next if pkg.env.any?
          end

          if requirement.do_check
            Logger.success("#{requirement.name}")
          else
            Logger.danger("#{requirement.name}")
          end
        end
      end
    end

    def install
      

      # Prewarm sudo, to prevent asking too much
      system('sudo -v')

      # Run pre tasks
      if @preTasks != nil
        Logger.log("Running pre tasks...")

        for task in @preTasks
          task_run(task)
        end
        Logger.log("")
      end
      
      # Install packages
      if @packages != nil
        Logger.log("Installing packages...")
        for pkg in @packages
          # Do an environment test
          if @opts.env
            # If package env is not defined, we expect it should always be installed regardless of environment
            # If user has defined an environment, skip if the set environment isn't in the package enviroment list 
            next if pkg.env.any? && !pkg.env.include?(@opts.env)
          else
            # If env contains anything, when env is not defined in opts, skip it, as this is not the correct env
            next if pkg.env.any?
          end

          if pkg.do_check
            Logger.success("#{pkg.name} is installed")
          else
            Logger.info("Installing: #{pkg.name}\r", use_print: true)
            if pkg.do_install
              Logger.success("#{pkg.name} was installed")
              $stdout.flush
            else
              Logger.danger("#{pkg.name} was not installed")
              $stdout.flush
            end
          end
        end  
        Logger.log("")
      end
      
      # Handle requirements
      if @requirements != nil 
        Logger.log("Handling requirements...")
        for requirement in @requirements
          # Do an environment test
          if @opts.env
            # If package env is not defined, we expect it should always be installed regardless of environment
            # If user has defined an environment, skip if the set environment isn't in the package enviroment list 
            next if requirement.env.any? && !requirement.env.include?(@opts.env)
          else
            # If env contains anything, when env is not defined in opts, skip it, as this is not the correct env
            next if requirement.env.any?
          end

          if requirement.do_check
            Logger.success("#{requirement.name}")
          else
            Logger.info("Handling: #{pkg.name}\r", use_print: true)
            if requirement.do_install
              Logger.success("#{requirement.name}")
              $stdout.flush
            else
              Logger.danger("#{requirement.name}")
              $stdout.flush
            end
          end
        end
        Logger.log("")
      end
    
      # Run post tasks
      if @postTasks != nil
        Logger.log("Running post tasks...")

        for task in @postTasks
          task_run(task)
        end
      end

    end

    def self.init(opts)
      sensible_file_name = "sensible.yml"

      if opts.file
        if opts.file.end_with?(".yml")
          sensible_file_name = opts.file
        else
          sensible_file_name = opts.file + ".yml"
        end
      end

      if not File.exist?(sensible_file_name)
        File.open(sensible_file_name, "w") do |f| 
          f.write(<<~EOF)
            ---
            packages:
            requirements:
          EOF
        end
        Logger.success("Created #{sensible_file_name}!")
      else 
        Logger.error("Cannot create #{sensible_file_name}, it already exists!")
      end
    end

    def task(env, file, dir, task)
      puts "  executing #{task}"
    end

    def task_run(task_name)
      # Load and parse the task file
      task_file_path = "#{@sensible_folder}/#{@tasks_folder}/#{task_name}.yml"
      
      # If task is not found, exit!
      if not File.exist?(task_file_path)
        pastel = Pastel.new
        Logger.error("Task: #{pastel.bold(task_name)} does not exist!")
        exit(1)
      end

      task = Task.new(YAML.load_file(task_file_path), "#{task_name}.yml", self)

      pastel = Pastel.new
      Logger.info("Running task: #{pastel.bold(task_name)}")
      
      # Check if we need to rerun the task
      if !task.do_check
        if !task.do_install
          Logger.error("The tasked failed!")
        else
          Logger.success("The task ran succesfully!")
        end
      else
        puts "Task check is already met"
      end
    end

    def task_list
      # Parse tasks
      tasks_path = "#{@sensible_folder}/#{@tasks_folder}"
      task_files = Dir.children(tasks_path)

      tasks = []
      for task_file in task_files
        tasks << Task.new(YAML.load_file("#{tasks_path}/#{task_file}"), task_file, self)
      end

      puts "Here is available tasks inside #{@sensible_folder}/#{tasks_folder}" if @opts.verbose

      pastel = Pastel.new
      for task in tasks
        Logger.log("#{pastel.blue.bold(task.file_name)}: #{task.name}")
      end
    end

    def task_create(task_name)
      tasks_path = "#{@sensible_folder}/#{@tasks_folder}"
      task_file_path = "#{tasks_path}/#{task_name}.yml"
      
      # Make sure the task don't already exist
      if File.exist?(task_file_path)
        pastel = Pastel.new
        Logger.error("Task: #{pastel.bold(task_name)} already exist!")
        exit(1)
      end
      
      # Create the task yaml file
      File.open(task_file_path, "w") do |f| 
        f.write(<<~EOF)
          ---
          name:
          description:
          install:
        EOF
      end

      pastel = Pastel.new
      Logger.success("Created the task: #{pastel.bold("#{task_name}.yml")}")  
    end
  end
end
