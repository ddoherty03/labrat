# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "labrat"

Gem::Specification.new do |spec|
  spec.name          = "labrat"
  spec.version       = Labrat::VERSION
  spec.authors       = ["Daniel E. Doherty"]
  spec.email         = ["ded-labrat@ddoherty.net"]

  spec.summary       = "Simple command-line based label printer."
  spec.homepage      = "http://github.com/ddoherty03/labrat"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://github.com/ddoherty03/labrat"
  spec.metadata["changelog_uri"] = "http://github.com/ddoherty03/labrat/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.post_install_message = 'To install config and label database files, run [sudo] labrat-install g.'
  spec.add_dependency "prawn", "~> 2.0"
  spec.add_dependency "activesupport"
  spec.add_dependency "fat_core"

  # Note: pry-byebug requires that pry be within the '0.13.0' version box.
  spec.add_development_dependency 'pry', '~> 0.13.0'
  spec.add_development_dependency 'pry-byebug', '>= 3.9.0'
  spec.add_development_dependency 'debug', '>= 1.0.0.beta'
end
