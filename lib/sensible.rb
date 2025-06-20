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

    attr_reader :tasks


    def initialize(sensibleFileName, opts, args)
      @opts = opts
      @args = args


      file_name = opts.file || sensibleFileName
      unless File.exist?(file_name)
          Logger.error("Required file not found: #{file_name}")
          exit(1)
      end

      # Load the Sensile file
      sensible_file_data = YAML.load_file(file_name)


      # Recursively go through all the tasks inside the sensible file
      # Add them to a list, that we will go through later
      @tasks = []
      def process_task(task_path, task_user = nil)
        task_yaml = YAML.load_file(task_path + '.yml')
        task = Task.new(task_yaml, task_path, task_user, self)
      
        if task.require
          task.require.each do |path|
            process_task(path, task.user)
          end
        end

        @tasks << task
      end 

      sensible_file_data.each do |key, value|
        case key
          when "require"
            value.each do |path|
              process_task(path)
            end
          when "tasks"
            value.each do |path|
              process_task(path)
            end
        end 
      end
    end


    # Run all the checks for packages and requirements
    def check

      @tasks.each_with_index do |task, index|
        pastel = Pastel.new
        if index > 0
          Logger.log("\n#{pastel.bold(task.name)}")
        else
          Logger.log("#{pastel.bold(task.name)}")
        end

        # Do an environment test
        # if @opts.env
        #   # If requirement env is not define, we expect it should always be installed regardless of environment
        #   # If user has defined an environment, skip if the set environment isn't in the package enviroment list 
        #   next if requirement.env.any? && !requirement.env.include?(@opts.env)
        # end
        if task.packages.length > 0
          if task.do_packages_check
            Logger.success("Packages installed!")
          else
            Logger.danger("Packages NOT installed!")
          end
        end

        if task.check
          if task.do_check
            Logger.success("Is installed!")
          else
            Logger.danger("Is NOT installed!")
          end
        end
      end
    end

    def install
      # Prewarm sudo, to prevent asking too much
      shell = Shell.new(self)
      shell.run_command('sudo -v', show_output: true)

      @tasks.each_with_index do |task, index|
        pastel = Pastel.new
        if index > 0
          Logger.log("\n#{pastel.bold(task.name)}")
        else
          Logger.log("#{pastel.bold(task.name)}")
        end


        # Do an environment test
        # if @opts.env
        #   # If requirement env is not define, we expect it should always be installed regardless of environment
        #   # If user has defined an environment, skip if the set environment isn't in the package enviroment list
        #   next if requirement.env.any? && !requirement.env.include?(@opts.env)
        # end
        if task.packages.length > 0
          if task.do_packages_check
            Logger.success("Packages installed!")
          else
            Logger.info("Installing packages...\r", use_print: true)
            if task.do_packages_install
              Logger.clear_line
              Logger.success("Packages installed!")
            else
              Logger.clear_line
              Logger.danger("Packages NOT installed!")
            end

            Logger.flush
          end
        end

        if task.check
          if task.do_check
            Logger.success("Is installed!")
          else
            if task.script
              Logger.info("Running task...\r", use_print: true)
              if task.do_script
                Logger.clear_line
                Logger.success("Is installed!")
              else
                Logger.clear_line
                Logger.danger("Is NOT installed!")
              end
              Logger.flush
            else
              Logger.danger("Is NOT installed!")
            end
          end
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
