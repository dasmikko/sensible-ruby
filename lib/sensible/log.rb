require 'tty-prompt'
require 'tty-spinner'
require 'pastel'

module Sensible
  $pastel = Pastel.new

  class Logger 
    def self.log(message, indent = 0, use_print: false)
        puts message
    end

    def self.success(message, indent = 0, use_print: false)
      spaceIndent = ""
      indent.times { |i| spaceIndent << " " }

      if use_print
        print "#{spaceIndent}#{$pastel.green("✔")} #{message}"
      else      
        puts "#{spaceIndent}#{$pastel.green("✔")} #{message}"
      end
    end

    def self.info(message, indent = 0, use_print: false)
      spaceIndent = ""
      indent.times { |i| spaceIndent << " " }
 
      if use_print
        print "#{spaceIndent}#{$pastel.blue("i")} #{message}"
      else      
        puts "#{spaceIndent}#{$pastel.blue("i")} #{message}"
      end
    end

    def self.danger(message, indent = 0, use_print: false)
      spaceIndent = ""
      indent.times { |i| spaceIndent << " " }
      
      if use_print
        print "#{spaceIndent}#{$pastel.red("✘")} #{message}"
      else      
        puts "#{spaceIndent}#{$pastel.red("✘")} #{message}"
      end      
    end

    def self.yes?(message, indent = 0)
      prompt = TTY::Prompt.new

      spaceIndent = ""
      indent.times { |i| spaceIndent << " " }

      prompt.yes?("#{spaceIndent}#{message}")
    end
  end
end
