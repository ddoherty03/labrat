# Your application should store and load data and configuration files to/from
# the directories pointed by the following environment variables:

# $XDG_CONFIG_HOME (default: "$HOME/.config"): user-specific configuration files.
# $XDG_CONFIG_DIRS (default: "/etc/xdg"): precedence-ordered set of system configuration directories.

module Labrat
  # This class is responsible for finding a config file, reading it, and
  # setting up an Options object to reflect the configuration.  We will use
  # YAML as the configuration format and look for the config file in some
  # standard places.
  class Config
    # Read the YAML-ized config files for app_name directories located in
    # either the xdg locations (containing any variant of base: base,
    # base.yml, or base.yaml) or in the classic locations (/etc/app_namerc,
    # /etc/app_name, ~/.app_namerc~, or ~/.app_name/base[.ya?ml]), or in both
    # and return a hash that set reflects the merging of those files according
    # to the following priorities, from highest to lowest:
    #
    # 1. A config file pointed to by the environment variable APP_NAME_CONFIG
    # 2. User classic config files
    # 3. User xdg config files for app_name,
    # 4. A config file pointed to by the environment variable APP_NAME_SYS_CONFIG
    # 5. System classic config files,
    # 6. System xdg config files for for app_name,
    #
    # If an environment variable is found pointing to a readable file, the
    # search for xdg and classic config files is skipped. Any dir_prefix is
    # pre-pended to search locations for the xdg and classic config file
    # directories so you can run this on a temporary directory set up for
    # testing.
    def self.read_config(app_name,
                         base: 'config', dir_prefix: '',
                         xdg: true, :classic: false)
      config = {}
      sys_configs = []
      sys_env_name = "#{app_name.upcase}_SYS_CONFIG"
      if ENV[sys_env_name] && File.readable?(File.expand_path(ENV[sys_env_name]))
        sys_configs = ENV[sys_env_name]
      else
        if xdg
          sys_configs += find_xdg_sys_config_files(app_name, base, dir_prefix)
        end
        if classic
          sys_configs += find_classic_sys_config_files(app_name, base, dir_prefix)
        end
      end
      config = merge_configs_from(sys_configs, config)

      usr_configs = []
      usr_env_name = "#{app_name.upcase}_CONFIG"
      if ENV[usr_env_name] && File.readable?(File.expand_path(ENV[usr_env_name]))
        usr_configs = ENV[usr_env_name]
      else
        if xdg
          usr_configs += find_xdg_usr_config_files(app_name, base, dir_prefix)
        end
        if classic
          usr_configs += find_classic_usr_config_files(app_name, base, dir_prefix)
        end
      end
      merge_configs_from(usr_configs, config)
    end

    # Return the absolute path names of all XDG system config files for
    # app_name with the basename variants of base. Prefix the search locations
    # with dir_prefix if given.
    def find_xdg_sys_config_files(app_name, base, dir_prefix)
      configs = []
      xdg_search_dirs = ENV['XDG_CONFIG_DIRS']&.split(':') || ['/etc/xdg']
      xdg_search_dirs.each do |dir|
        dir = File.expand_path(dir)
        dir = File.join(dir_prefix, dir) unless dir_prefix.nil? || dir_prefix.strip.empty?
        base = app_name if base.nil? || base.strip.empty?
        base_candidates = ["#{base}" "#{base}.yml", "#{base}.yaml", "#{base.cfg}", "#{base}.config"]
        configs += base_candidates.find { |b| File.readable?(File.join(dir, b)) }
      end
      configs
    end

    # Return the absolute path names of all "classic" system config files for
    # app_name with the basename variants of base. Return the highest priority
    # files first, lowest last.  Prefix the search locations with dir_prefix if
    # given.
    def find_classic_sys_config_files(app_name, base, dir_prefix)
      dir_prefix ||= ''
      configs = []
      env_config = ENV["#{app_name.upcase}_SYS_CONFIG"]
      if env_config && File.readable?((config = File.join(dir_prefix, File.expand_path(env_config))))
        configs = [ config ]
      elsif File.readable?(config = (File.join(dir_prefix, "/etc/#{app_name}")))
        configs = [ config ]
      elsif File.readable?(config = (File.join(dir_prefix, "/etc/#{app_name}rc")))
        configs = [ config ]
      else
        dir = File.join(dir_prefix, "/etc/#{app_name}")
        if Dir.exist?(dir)
          base = app_name if base.nil? || base.strip.empty?
          base_candidates = ["#{base}" "#{base}.yml", "#{base}.yaml", "#{base.cfg}", "#{base}.config"]
          config = base_candidates.find { |b| File.readable?(File.join(dir, b)) }
          configs = [ config ] if config
        end
      end
      configs
    end

    # Return the absolute path names of all XDG user config files for app_name
    # with the basename variants of base. Prefix the search locations with
    # dir_prefix if given.
    def find_xdg_user_config_files(app_name, base, dir_prefix)
      dir_prefix ||= ''
      base ||= (base&.strip || app_name)
      configs = []
      xdg_search_dirs = ENV['XDG_CONFIG_HOME']&.split(':') || ['~/.config']
      xdg_search_dirs.each do |dir|
        dir = File.expand_path(File.join(dir, app_name))
        dir = File.join(dir_prefix, dir) unless dir_prefix.strip.empty?
        next unless Dir.exist?(dir)

        base_candidates = ["#{base}" "#{base}.yml", "#{base}.yaml", "#{base.cfg}", "#{base}.config"]
        configs += base_candidates.find { |b| File.readable?(File.join(dir, b)) }
      end
      configs
    end

    # Return the absolute path names of all "classic" system config files for
    # app_name with the basename variants of base. Return the highest priority
    # files first, lowest last.  Prefix the search locations with dir_prefix if
    # given.
    def find_classic_user_config_files(app_name, base, dir_prefix)
      dir_prefix ||= ''
      base ||= (base&.strip || app_name)
      base_candidates = ["#{base}" "#{base}.yml", "#{base}.yaml", "#{base.cfg}", "#{base}.config"]
      configs = []
      env_config = ENV["#{app_name.upcase}_CONFIG"]
      if env_config && File.readable?((config = File.join(dir_prefix, File.expand_path(env_config))))
        configs = [ config ]
      elsif File.readable?(config = (File.join(dir_prefix, File.expand_path("~/.#{app_name}rc"))))
        configs = [ config ]
      elsif Dir.exist?(config_dir = (File.join(dir_prefix, File.expand_path("~/.#{app_name}"))))
        config = base_candidates.find { |b| File.readable?(File.join(config_dir, b)) }
        configs = [ config ]
      end
      configs
    end

    # Given the name of an environment variable for colon-separated config
    # paths and a default directory to use if the environment variable is not
    # set, return an array of directories within those having a subdirectory
    # with the name app_dir_name in which to search for config files.
    def self.find_config_dirs(env_path_var, default_dir, app_dir_name = 'labrat')
      env = ENV[env_path_var]
      default_dir = File.join(File.expand_path(default_dir), app_dir_name)
      if env
        env.split(':').select { |d| Dir.exist?(File.join(d, app_dir_name)) }
      elsif Dir.exist?(default_dir)
        [default_dir]
      else
        []
      end
    end

    # Merge the settings from config files with the name config_name from the
    # given directories, dirs, into the given Options object.  Per the XDG
    # specification, directories listed first are the most important, so we
    # merge them in reverse order so that earlier-listed config directories
    # override later-listed ones.
    def self.merge_configs_from(dirs = [], config_name, into: Options.new)
      dirs.reverse.each do |dir|
        config_file = File.join(dir, config_name)
        if File.readable?(config_file)
          yml = File.read(config_file)
          merge_config_string(yml, into)
        end
      end
      into
    end

    # Merge the given YAML string into the given Options object and return it.
    def self.merge_config_string(str, op)
      hsh = YAML.load(str)
      op.merge_hash
    end
  end
end
