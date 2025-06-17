require_relative 'package'
require_relative 'parse'

module Sensible
  class Requirement < Task
    attr_reader :packages
    # Pretty much the same as package right now

    def initialize(requirement_file_name, sensible)

      
      requirement_file_path = "#{sensible.sensible_folder}/#{sensible.requirements_folder}/#{requirement_file_name}.yml"
      requirement_data = YAML.load_file(requirement_file_path)
      
      puts requirement_data 

      @packages = Parse::parse_sensible_packages(sensible_hash_list['packages'], sensible)
    end
  end
end
