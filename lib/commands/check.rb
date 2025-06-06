require "thor"
require_relative "../config"

module Sensible
    module Commands
        class Check < Thor
            desc "run", "Run the check command"
            def check
                sensibleConfig = Config::readSensibleFile
                puts sensibleConfig
            end
        end 
    end
end