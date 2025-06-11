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

      installed_packages = []
      failed_packages = []

      for pkg in @packages
        if pkg.do_check
          installed_packages.append(pkg)
        else
          Logger.info("Installing: #{pkg.name}")
          was_installed = pkg.do_install

          if was_installed
            installed_packages.append(pkg)
          else
            failed_packages.append(pkg)
          end
        end
      end  
      
      if installed_packages.length > 0
        Logger.log("These packages was installed succesfully:")
        for pkg in installed_packages
          Logger.success("#{pkg.name}", 2)
        end
      end

      if failed_packages.length > 0
        Logger.log("These packages was installed unsuccesfully:")
        for pkg in failed_packages
          Logger.danger("#{pkg.name}", 2)
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
