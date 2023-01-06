# frozen_string_literal: true

require 'simplecov'
SimpleCov.command_name 'Rspec'

require "labrat"

require 'pry'
require 'debug'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.raise_errors_for_deprecations!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
end

include Labrat

# Conversion factors from given measure to Adobe points
MM = 2.83464566929
CM = 28.3464566929
IN = 72.0
EPS = 0.000001

# Put files here to test file-system dependent specs.
SANDBOX_DIR = File.join(__dir__, 'support/sandbox')

# Put contents in path relative to SANDBOX
def setup_test_file(path, content)
  path = File.expand_path(path)
  test_path = File.join(SANDBOX_DIR, path)
  dir_part = File.dirname(test_path)
  FileUtils.mkdir_p(dir_part) unless Dir.exist?(dir_part)
  File.write(test_path, content)
end
