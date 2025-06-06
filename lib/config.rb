require 'yaml'

module Sensible
    class Config
        def readSensibleFile
            currentDirname = File.basename(Dir.getwd)
    
            data = YAML.load_file("#{currentDirname}/sensible.yml")
        end
    end
end
