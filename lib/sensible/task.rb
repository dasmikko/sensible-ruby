require_relative 'package'

module Sensible
  class Task < Package
    attr_reader :task

    def initialize(taskHash, sensible)
      super(taskHash, sensible)
      @task = taskHash['task']
    end
    
    def do_check
      puts "this is a task check"
    end

  end
end
