require 'tty-prompt'
require 'pastel'

module Sensible
    $pastel = Pastel.new

    class SensibleLog 
        def self.log(message)
            puts message
        end

        def self.success(message)
            puts $pastel.green("✔") + " #{message}"
        end

        def self.danger(message)
            puts $pastel.red("✘") + " #{message}"
        end

    end
end
