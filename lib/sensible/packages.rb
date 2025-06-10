require_relative 'file'
require_relative 'log'
require 'tty-prompt'
require 'pastel'

module Sensible
    class SensiblePackages
        def self.checkPackages
            sensibleFile = SensibleFile.readSensibleFile
            packages = sensibleFile["packages"] 
            prompt = TTY::Prompt.new

            puts "Check the sensible.yml file dependencies"
            pastel = Pastel.new

            for package in packages do
                isInstalled = checkPackage(package)
                if isInstalled
                    SensibleLog.success("#{package} is installed")
                else
                    SensibleLog.danger("#{package} is NOT installed")
                    if prompt.yes?("Do you want to install #{package}")
                        installPackage(package)
                    end
                end
            end
        end

        def self.installPackages
            sensibleFile = SensibleFile.readSensibleFile
            packages = sensibleFile["packages"] 

            puts 'Installing missing packages...'

            for package in packages do
                isInstalled = checkPackage(package)
                if !isInstalled
                    installPackage(package)
                end
            end

        end

        def self.checkPackage(packageName)
            result = `rpm -q #{packageName}`
            
            if result.include? 'is not installed'
                return false
            end

            return true
        end

        def self.installPackage(packageName)
            system("sudo dnf install -y #{packageName}")
        end
    end
end