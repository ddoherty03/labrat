# frozen_string_literal: true

module Labrat
  module LabelDb
    class << self
      # Module-level variable to hold the merged database.
      attr_accessor :db
    end

    # Read in the Labrat database of label settings, merging system and user
    # databases.
    def self.read(dir_prefix: '')
      self.db = Config.read('labrat', base: 'labeldb', dir_prefix: dir_prefix).
        transform_keys(&:to_sym)
    end

    # Return a hash of config settings for the label named by labname.
    def self.[](labname)
      read unless db
      db[labname.to_sym] || {}
    end

    # Set a runtime configuration for a single labelname.
    def self.[]=(labname, config = {})
      read unless db
      db[labname.to_sym] = config
    end

    # Return an Array of label names.
    def self.known_names
      read unless db
      db.keys.sort
    end

    def self.db_paths(dir_prefix = '')
      system_db_paths(dir_prefix) + user_db_paths(dir_prefix)
    end

    def self.system_db_paths(dir_prefix = '')
      paths = Config.config_paths('labrat', base: 'labeldb', dir_prefix: dir_prefix)
      paths[:system]
    end

    def self.user_db_paths(dir_prefix = '')
      paths = Config.config_paths('labrat', base: 'labeldb', dir_prefix: dir_prefix)
      paths[:user]
    end
  end
end
