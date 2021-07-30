# frozen_string_literal: true

require_relative "lib/labrat/version"

Gem::Specification.new do |spec|
  spec.name          = "labrat"
  spec.version       = Labrat::VERSION
  spec.authors       = ["Daniel E. Doherty"]
  spec.email         = ["ded-labrat@ddoherty.net"]

  spec.summary       = "Simple command-line based label printer."
  spec.homepage      = "http://github.com/ddoherty03/labrat"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://github.com/ddoherty03/labrat"
  spec.metadata["changelog_uri"] = "http://github.com/ddoherty03/labrat/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "prawn", "~> 2.0"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
