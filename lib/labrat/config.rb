# frozen_string_literal: true

module Labrat
  # This class is responsible for finding a config files, reading them, and
  # returning a Hash to reflect the configuration.  We use YAML as the
  # configuration format and look for the config file in the standard places.
  class Config
    # Return a Hash of the YAML-ized config files for app_name directories.
    # Config file may be located in either the xdg locations (containing any
    # variant of base: base, base.yml, or base.yaml) or in the classic
    # locations (/etc/app_namerc, /etc/app_name, ~/.app_namerc~, or
    # ~/.app_name/base[.ya?ml]). Return a hash that reflects the merging of
    # those files according to the following priorities, from highest to
    # lowest:
    #
    # 1. A config file pointed to by the environment variable APPNAME_CONFIG
    # 2. User classic config files
    # 3. User xdg config files for app_name,
    # 4. A config file pointed to by the environment variable APPNAME_SYS_CONFIG
    # 5. System classic config files,
    # 6. System xdg config files for for app_name,
    #
    # If an environment variable is found, the search for xdg and classic
    # config files is skipped. Any dir_prefix is pre-pended to search
    # locations environment, xdg and classic config paths so you can run this
    # on a temporary directory set up for testing.
    def self.read(app_name, base: 'config', dir_prefix: '', xdg: true, verbose: false)
      paths = config_paths(app_name, base: base, dir_prefix: dir_prefix, xdg: xdg)
      sys_configs = paths[:system]
      usr_configs = paths[:user]
      merge_configs_from((sys_configs + usr_configs).compact, verbose: verbose)
    end

    def self.config_paths(app_name, base: 'config', dir_prefix: '', xdg: true)
      sys_configs = []
      sys_env_name = "#{app_name.upcase}_SYS_CONFIG"
      if ENV[sys_env_name]
        sys_fname = File.join(dir_prefix, File.expand_path(ENV[sys_env_name]))
        sys_configs << sys_fname if File.readable?(sys_fname)
      else
        sys_configs +=
          if xdg
            find_xdg_sys_config_files(app_name, base, dir_prefix)
          else
            find_classic_sys_config_files(app_name, base, dir_prefix)
          end
      end

      usr_configs = []
      usr_env_name = "#{app_name.upcase}_CONFIG"
      if ENV[usr_env_name]
        usr_fname = File.join(dir_prefix, File.expand_path(ENV[usr_env_name]))
        usr_configs << usr_fname if File.readable?(usr_fname)
      else
        usr_configs <<
          if xdg
            find_xdg_user_config_file(app_name, base, dir_prefix)
          else
            find_classic_user_config_file(app_name, dir_prefix)
          end
      end
      { system: sys_configs.compact, user: usr_configs.compact }
    end

    # Merge the settings from the given Array of config files in order from
    # lowest priority to highest priority, starting with an empty hash.  Any
    # values of the top-level hash that are themselves Hashes are merged
    # recursively.
    def self.merge_configs_from(files = [], verbose: false)
      hash = {}
      files.each do |f|
        next unless File.readable?(f)

        yml_hash = YAML.load_file(f)
        next unless yml_hash

        if yml_hash.is_a?(Hash)
          yml_hash = yml_hash
        else
          raise "Error loading file #{f}:\n#{File.read(f)[0..500]}"
        end
        yml_hash.report("Merging config from file '#{f}") if verbose
        hash.deep_merge!(yml_hash)
      end
      hash
    end

    ########################################################################
    # XDG config files
    ########################################################################

    # From the XDG standard:
    # Your application should store and load data and configuration files to/from
    # the directories pointed by the following environment variables:
    #
    # $XDG_CONFIG_HOME (default: "$HOME/.config"): user-specific configuration files.
    # $XDG_CONFIG_DIRS (default: "/etc/xdg"): precedence-ordered set of system configuration directories.

    # Return the absolute path names of all XDG system config files for
    # app_name with the basename variants of base. Return the lowest priority
    # files first, highest last. Prefix the search locations with dir_prefix
    # if given.
    def self.find_xdg_sys_config_files(app_name, base, dir_prefix)
      configs = []
      xdg_search_dirs = ENV['XDG_CONFIG_DIRS']&.split(':')&.reverse || ['/etc/xdg']
      xdg_search_dirs.each do |dir|
        dir = File.expand_path(File.join(dir, app_name))
        dir = File.join(dir_prefix, dir) unless dir_prefix.nil? || dir_prefix.strip.empty?
        base = app_name if base.nil? || base.strip.empty?
        base_candidates = [
          base.to_s,
          "#{base}.yml",
          "#{base}.yaml",
          "#{base}.cfg",
          "#{base}.config"
        ]
        config_fname = base_candidates.find { |b| File.readable?(File.join(dir, b)) }
        configs << File.join(dir, config_fname) if config_fname
      end
      configs
    end

    # Return the absolute path name of any XDG user config files for app_name
    # with the basename variants of base. The XDG_CONFIG_HOME environment
    # variable for the user configs is intended to be the name of a single xdg
    # config directory, not a list of colon-separated directories as for the
    # system config. Return the name of a config file for this app in
    # XDG_CONFIG_HOME (or ~/.config by default).  Prefix the search location
    # with dir_prefix if given.
    def self.find_xdg_user_config_file(app_name, base, dir_prefix)
      dir_prefix ||= ''
      base ||= base&.strip || app_name
      xdg_search_dir = ENV['XDG_CONFIG_HOME'] || ['~/.config']
      dir = File.expand_path(File.join(xdg_search_dir, app_name))
      dir = File.join(dir_prefix, dir) unless dir_prefix.strip.empty?
      return unless Dir.exist?(dir)

      base_candidates = [
        base.to_s,
        "#{base}.yml",
        "#{base}.yaml",
        "#{base}.cfg",
        "#{base}.config"
      ]
      config_fname = base_candidates.find { |b| File.readable?(File.join(dir, b)) }
      if config_fname
        File.join(dir, config_fname)
      end
    end

    ########################################################################
    # Classic config files
    ########################################################################

    # Return the absolute path names of all "classic" system config files for
    # app_name with the basename variants of base. Return the lowest priority
    # files first, highest last.  Prefix the search locations with dir_prefix
    # if given.
    def self.find_classic_sys_config_files(app_name, base, dir_prefix)
      dir_prefix ||= ''
      configs = []
      env_config = ENV["#{app_name.upcase}_SYS_CONFIG"]
      if env_config && File.readable?((config = File.join(dir_prefix, File.expand_path(env_config))))
        configs = [config]
      elsif File.readable?(config = File.join(dir_prefix, "/etc/#{app_name}"))
        configs = [config]
      elsif File.readable?(config = File.join(dir_prefix, "/etc/#{app_name}rc"))
        configs = [config]
      else
        dir = File.join(dir_prefix, "/etc/#{app_name}")
        if Dir.exist?(dir)
          base = app_name if base.nil? || base.strip.empty?
          base_candidates = [
            base.to_s + "#{base}.yml",
            "#{base}.yaml",
            "#{base}.cfg",
            "#{base}.config"
          ]
          config = base_candidates.find { |b| File.readable?(File.join(dir, b)) }
          configs = [File.join(dir, config)] if config
        end
      end
      configs
    end

    # Return the absolute path names of all "classic" system config files for
    # app_name with the basename variants of base. Return the lowest priority
    # files first, highest last.  Prefix the search locations with dir_prefix if
    # given.
    def self.find_classic_user_config_file(app_name, dir_prefix)
      dir_prefix ||= ''
      config_fname = nil
      env_config = ENV["#{app_name.upcase}_CONFIG"]
      if env_config && File.readable?((config = File.join(dir_prefix, File.expand_path(env_config))))
        config_fname = config
      elsif Dir.exist?(config_dir = File.join(dir_prefix, File.expand_path("~/.#{app_name}")))
        base_candidates = ["config.yml", "config.yaml", "config"]
        base_fname = base_candidates.find { |b| File.readable?(File.join(config_dir, b)) }
        config_fname = File.join(config_dir, base_fname)
      elsif Dir.exist?(config_dir = File.join(dir_prefix, File.expand_path('~/')))
        base_candidates = [
          ".#{app_name}",
          ".#{app_name}rc",
          ".#{app_name}.yml",
          ".#{app_name}.yaml",
          ".#{app_name}.cfg",
          ".#{app_name}.config"
        ]
        base_fname = base_candidates.find { |b| File.readable?(File.join(config_dir, b)) }
        config_fname = File.join(config_dir, base_fname)
      end
      config_fname
    end
  end
end
