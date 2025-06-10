require_relative 'file'

module Sensible
    class SensibleCheck 
        def self.checkDependencies
            puts "Check the sensible.yml file dependencies"

            for package in SensibleFile.packages do
                puts package
            end
        end
    end
end