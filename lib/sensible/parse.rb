require_relative 'task'
require_relative 'package'

module Sensible
  class Parse
    
    # Parse the package list from sensible.yml
    def self.parse_sensible_packages(sensible_hash_list, sensible)
      list = []
      for pkg in sensible_hash_list
        list.append(Package.new(pkg, sensible))
      end
      return list
    end

    # Parse the task list from sensible.yml
    def self.parse_sensible_tasks(sensible_hash_list, sensible)
      list = []
      for task in sensible_hash_list
        list.append(Task.new(tash, sensible))
      end
      return list
    end

  end
end