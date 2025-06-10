require_relative 'file'

module Sensible
    class SensiblePackages
        def self.checkPackages
            sensibleFile = SensibleFile.readSensibleFile
            packages = sensibleFile["packages"] 
            
            puts "Check the sensible.yml file dependencies"

            for package in packages do
                isInstalled = checkPackage(package)
                if isInstalled
                    puts "#{package} is installed"
                else
                    puts "#{package} is NOT installed"
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