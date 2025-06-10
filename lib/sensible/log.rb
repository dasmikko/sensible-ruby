require 'tty-prompt'
require 'pastel'

module Sensible
    $pastel = Pastel.new

    class SensibleLog 
        def self.log(message)
            puts message
        end

        def self.success(message, indent = 0)
            spaceIndent = ""
            indent.times { |i| spaceIndent << " " }

            puts "#{spaceIndent}#{$pastel.green("✔")} #{message}"
        end

        def self.danger(message, indent = 0)
            spaceIndent = ""
            indent.times { |i| spaceIndent << " " }

            puts "#{spaceIndent}#{$pastel.red("✘")} #{message}"
        end

        def self.yes?(message, indent = 0)
            prompt = TTY::Prompt.new

            spaceIndent = ""
            indent.times { |i| spaceIndent << " " }

            prompt.yes?("#{spaceIndent}#{message}")
        end

    end
end
