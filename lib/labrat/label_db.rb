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
  end
end
