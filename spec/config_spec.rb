# frozen_string_literal: true

SANDBOX_DIR = File.join(__dir__, 'support/sandbox')

RSpec.describe Config do
  before :each do
    # Save these, since they're not specific to this app.
    @xdg_config_dirs = ENV['XDG_CONFIG_DIRS']
    @xdg_config_home = ENV['XDG_CONFIG_HOME']
  end

  after :each do
    # Restore
    ENV['XDG_CONFIG_DIRS'] = @xdg_config_dirs
    ENV['XDG_CONFIG_HOME'] = @xdg_config_home
    # Remove anything set in examples
    ENV['LABRAT_SYS_CONFIG'] = nil
    ENV['LABRAT_CONFIG'] = nil
    FileUtils.rm_rf(SANDBOX_DIR)
  end

  def setup_test_file(path, content)
    path = File.expand_path(path)
    test_path = File.join(SANDBOX_DIR, path)
    dir_part = File.dirname(test_path)
    FileUtils.mkdir_p(dir_part) unless Dir.exist?(dir_part)
    File.write(test_path, content)
  end

  describe 'Basic YAML reading' do
    let(:yaml_str) do
      <<~YAML
      ---
      doe: "a deer, a female deer"
      ray: "a drop of golden sun"
      pi: 3.14159
      xmas: true
      french-hens: 3
      calling-birds:
        - huey
        - dewey
        - louie
        - fred
      xmas-fifth-day:
        calling-birds: four
        french-hens: 3
        golden-rings: 5
        partridges:
          count: 1
          location: "a pear tree"
        turtle-doves: two
    YAML
    end

    it 'can read a yaml string' do
      struct = YAML.load(yaml_str)
      expect(struct.keys).to include('doe')
    end
  end

  describe 'Reading XDG config files' do
    it 'can read from an xdg system config file' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      setup_test_file('/etc/xdg/labrat/config.yml', config_yml)
      hsh = Config.read('labrat', xdg: true, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can read from an XDG_CONFIG_DIRS xdg system directory config file' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
    YAML
      setup_test_file('/lib/junk/labrat/config.yml', config_yml)
      config2_yml = <<~YAML
      page-width: 3cm
      page-height: 10cm
      delta-x: -4pt
      printer: dymo4
      rows: 10
      columns: 3
    YAML
      setup_test_file('/lib/lowjunk/labrat/config.yml', config2_yml)

      # The first directory in the ENV variable list should take precedence.
      ENV['XDG_CONFIG_DIRS'] = "/lib/junk:#{ENV['XDG_CONFIG_DIRS']}:/lib/lowjunk"
      hsh = Config.read('labrat', xdg: true, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      # Since these were not specified in the high-priority config, but were in
      # the low-priority config, they get set.
      expect(op.printer).to eq('dymo4')
      expect(op.rows).to eq(10)
      expect(op.columns).to eq(3)
    end

    it 'can read from an xdg system ENV-specified config file' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      ENV['LABRAT_SYS_CONFIG'] = '/etc/labrat.yml'
      setup_test_file(ENV['LABRAT_SYS_CONFIG'], config_yml)
      hsh = Config.read('labrat', xdg: true, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can read from an xdg user config file' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      setup_test_file("/home/#{ENV['USER']}/.config/labrat/config.yml", config_yml)
      hsh = Config.read('labrat', xdg: true, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can read from an xdg ENV-specified user config file' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      ENV['LABRAT_CONFIG'] = "/home/#{ENV['USER']}/.labrc"
      setup_test_file(ENV['LABRAT_CONFIG'], config_yml)
      hsh = Config.read('labrat', xdg: true, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can merge an xdg user config into an xdg system config file' do
      sys_config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      setup_test_file('/etc/xdg/labrat/config.yml', sys_config_yml)
      usr_config_yml = <<~YAML
      page-height: 102mm
      delta-x: -3mm
    YAML
      setup_test_file("/home/#{ENV['USER']}/.config/labrat/config.yml", usr_config_yml)
      hsh = Config.read('labrat', xdg: true, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(102 * MM)
      expect(op.delta_x).to be_within(EPS).of(-3 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can read from an XDG_CONFIG_HOME xdg user directory config file' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
    YAML
      setup_test_file('~/.foncig/labrat/config.yml', config_yml)

      # The first directory in the ENV variable list should take precedence.
      ENV['XDG_CONFIG_HOME'] = "~/.foncig"
      hsh = Config.read('labrat', xdg: true, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
    end
  end

  describe 'Reading classic config files' do
    it 'can read from an classic system config file' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      ENV['LABRAT_SYS_CONFIG'] = '/etc/labrat/config.yaml'
      setup_test_file(ENV['LABRAT_SYS_CONFIG'], config_yml)
      hsh = Config.read('labrat', xdg: false, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it "can read from an classic user config file in ENV['LABRAT_CONFIG']" do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      ENV['LABRAT_CONFIG'] = '~/junk/random/lr.y'
      setup_test_file(ENV['LABRAT_CONFIG'], config_yml)
      hsh = Config.read('labrat', xdg: false, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can read from an classic user rc-style config file in HOME' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      setup_test_file('~/.labratrc', config_yml)
      hsh = Config.read('labrat', xdg: false, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can read from an classic ~/.labrat config dir in HOME' do
      config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      setup_test_file('~/.labrat/config', config_yml)
      hsh = Config.read('labrat', xdg: false, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(101 * MM)
      expect(op.delta_x).to be_within(EPS).of(-4 * MM)
      expect(op.delta_y).to be_within(EPS).of(1 * CM)
      expect(op.nlsep).to eq('%%')
      expect(op.printer).to eq('seiko3')
    end

    it 'can read from classic system and user config files' do
      sys_config_yml = <<~YAML
      page-width: 33mm
      page-height: 101mm
      delta-x: -4mm
      delta-y: 1cm
      nlsep: '%%'
      printer: seiko3
    YAML
      ENV['LABRAT_SYS_CONFIG'] = '/etc/labrat/config.yaml'
      setup_test_file(ENV['LABRAT_SYS_CONFIG'], sys_config_yml)

      usr_config_yml = <<~YAML
      page-height: 102mm
      delta-x: -7mm
      delta-y: +30mm
      nlsep: '++'
    YAML
      setup_test_file('~/.labrat/config.yml', usr_config_yml)
      hsh = Config.read('labrat', xdg: false, dir_prefix: SANDBOX_DIR)
      op = ArgParser.new.from_hash(hsh)
      expect(op.page_width).to be_within(EPS).of(33 * MM)
      expect(op.page_height).to be_within(EPS).of(102 * MM)
      expect(op.delta_x).to be_within(EPS).of(-7 * MM)
      expect(op.delta_y).to be_within(EPS).of(3 * CM)
      expect(op.nlsep).to eq('++')
      expect(op.printer).to eq('seiko3')
    end
  end
end
