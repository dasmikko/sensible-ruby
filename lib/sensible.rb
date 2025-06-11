# frozen_string_literal: true
require 'yaml'
require_relative "sensible/version"
require_relative "sensible/package"
require_relative "sensible/log"
require_relative "sensible/parse"

module Sensible
  class Error < StandardError; end

  class Sensible

    attr_reader :packages
    attr_reader :requirements


    def initialize(sensibleFileName, opts)
      file_name = opts.file || sensibleFileName
      unless File.exist?(file_name)
          STDERR.puts "❌ Error: Required file not found: #{file_name}"
          exit(1)
      end

      # Load the Sensile file
      sensible_file_data = YAML.load_file(file_name)

      # Parse packages
      @packages = Parse.parse_sensible_packages(sensible_file_data['packages'])
    end


    # Run all the checks for packages and requirements
    def check
      Logger.log("Checking for installed packages...")
      
      for pkg in @packages
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

    def self.init(env, file, dir)
      puts "  initializing"
    end

    def self.task(env, file, dir, task)
      puts "  executing #{task}"
    end
  end
end
