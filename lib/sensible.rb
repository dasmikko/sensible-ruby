require "thor"
require_relative "version"
require_relative "commands/check"

module Sensible
    class CLI < Thor
        map %w[--version -v] => :version

        desc "hello NAME", "Say hello to NAME"
        def hello(name)
            puts "Hello, #{name}!"
        end

        desc "command COMMAND", "Run a shell command"
        def command(command)
            result = system "#{command}"
            puts "result: #{result}"
        end

        desc "scripttest", "Runs a shell script"
        def scripttest
            puts "Running shell script!"
            result = system "./shelltest.sh"
            puts "result: #{result}"
        end

        desc "check", "Checks dependencies"
        subcommand "check", Sensible::Commands::Check

        desc "version", "Shows version"
        def version
            puts VERSION
        end
    end
end