# frozen_string_literal: true

require_relative "lib/sensible/version"

Gem::Specification.new do |spec|
  spec.name = "sensible-cli"
  spec.version = Sensible::VERSION
  spec.authors = ["Mikkel Jensen"]
  spec.email = ["dasmikko@gmail.com"]

  spec.summary = "A small tool to manage projects."
  spec.description = "A small tool to manage projects, making shell scripts easier to manage, and faster to setup projects!"
  spec.homepage = "https://github.com/dasmikko/sensible-ruby"
  spec.required_ruby_version = ">= 3.1.0"


  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "shellopts", ">= 2.6.1", "< 3"
  spec.add_dependency "tty-which"
  spec.add_dependency "tty-command"
  spec.add_dependency "pastel"
  spec.add_dependency "tty-spinner"
  spec.add_dependency "tty-prompt"

  # For more informatioscript: sudo dnf update --refresh
n and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  # Add your production dependencies here
  # spec.add_dependency GEM [, VERSION]

  # Add your development dependencies here
  # spec.add_development_dependency GEM [, VERSION]

  # Also un-comment in spec/spec_helper to use simplecov
  # spec.add_development_dependency "simplecov"
end
