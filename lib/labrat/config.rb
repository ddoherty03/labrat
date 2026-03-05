# frozen_string_literal: true

# A thin wrapper around FatConfig.
module Labrat
  module Config
    def self.read(app_name, base: 'config', dir_prefix: '', xdg: true, verbose: false)
      reader = FatConfig::Reader.new(app_name, xdg:, root_prefix: dir_prefix)
      reader.read(verbose:)
    end
  end
end
