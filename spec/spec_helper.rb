# frozen_string_literal: true

require "labrat"

require 'pry'
require 'pry-byebug'
# require 'debug'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
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
