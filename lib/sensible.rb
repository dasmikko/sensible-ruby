# frozen_string_literal: true

require_relative "sensible/version"
require_relative "sensible/packages"
require_relative "sensible/file"

#require_relative "sensible/alle-andre-filer-under-lib/sensible-du-skal-bruge"

module Sensible
  class Error < StandardError; end

  def self.check(env, file, dir)
    Sensible::SensiblePackages.checkPackages
  end

  def self.install(env, file, dir)
    Sensible::SensiblePackages.installPackages
  end

  def self.init(env, file, dir)
    puts "  initializing"
  end

  def self.task(env, file, dir, task)
    puts "  executing #{task}"
  end
end
