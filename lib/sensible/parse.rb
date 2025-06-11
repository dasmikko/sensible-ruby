
module Sensible
  class Parse
    
    # Parse the package list from sensible.yml
    def self.parse_sensible_packages(sensible_hash_list)
      list = []
      for pkg in sensible_hash_list
        list.append(Package.new(pkg, self))
      end
      return list
    end

  end
end