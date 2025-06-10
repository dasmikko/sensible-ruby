require 'yaml'

module Sensible
    @sensibleFile = nil

    class SensibleFile
        def self.readSensibleFile
            currentDirname = File.basename(Dir.getwd)
            pathToSensibleFile = "sensible.yml"

            unless File.exist?(pathToSensibleFile)
                STDERR.puts "❌ Error: Required file not found: #{pathToSensibleFile}"
                exit(1)
            end

            puts "Reading sensible file..."

            @sensibleFile = YAML.load_file(pathToSensibleFile)
        end

        def self.data
            @sensibleFile
        end

        def self.packages 
            @sensibleFile['packages']
        end
    end
end

