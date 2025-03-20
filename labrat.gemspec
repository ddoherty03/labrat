# frozen_string_literal: true

require_relative "lib/labrat/version"

Gem::Specification.new do |spec|
  spec.name          = "labrat"
  spec.version       = Labrat::VERSION
  spec.authors       = ["Daniel E. Doherty"]
  spec.email         = ["ded-labrat@ddoherty.net"]

  spec.summary       = "Command-line and Emacs label print software."
  spec.description = <<~DESC

    Labrat is a linux command-line program for quickly printing labels.  Labrat uses
    the wonderful Prawn gem to generate PDF files with label formatting in mind. With
    labrat properly configured, printing a label is as simple as:

    $ labrat 'Income Taxes 2021 ~~ Example Maker, Inc.'

    And you will get a two-line file-folder label with the text centered. It can
    print on dymo label printer rolls or Avery sheet labels.  It knows the layout of
    most Avery label types.

    For Emacs users, labrat includes elisp code for invoking labrat from within a
    buffer, providing a quick way to print labels.

  DESC

  spec.homepage = "http://github.com/ddoherty03/labrat"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://github.com/ddoherty03/labrat"
  spec.metadata["changelog_uri"] = "http://github.com/ddoherty03/labrat/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x[git ls-files -z].split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/labrat}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.post_install_message = 'To install config and label database files, run labrat-install.'
  spec.add_dependency "activesupport"
  spec.add_dependency "fat_config", '>=0.4.2'
  spec.add_dependency "fat_core"
  spec.add_dependency "matrix"
  spec.add_dependency "prawn", "~> 2.0"
end
