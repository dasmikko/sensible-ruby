require 'yaml'

module Sensible
    class SensibleFile
        def self.readSensibleFile
            currentDirname = File.basename(Dir.getwd)
            pathToSensibleFile = "#{currentDirname}/sensible.yml"

            puts pathToSensibleFile

            unless File.exist?(pathToSensibleFile)
                STDERR.puts "❌ Error: Required file not found: path/to/your/file.txt"
                exit(1)
            end

            data = YAML.load_file("#{currentDirname}/sensible.yml")
            puts data
        end
    end
end

