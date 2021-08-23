# frozen_string_literal: true

SANDBOX_DIR = File.join(__dir__, 'support/sandbox')

RSpec.describe LabelDb do
  before :each do
    # Save these, since they're not specific to this app.
    @xdg_config_dirs = ENV['XDG_CONFIG_DIRS']
    @xdg_config_home = ENV['XDG_CONFIG_HOME']
    @sys_db_path = File.join(__dir__, '../lib/config_files/system_label_db.yml')
    @sys_db = File.read(@sys_db_path)
    @user_db_path = File.join(__dir__, '../lib/config_files/user_label_db.yml')
    @user_db = File.read(@user_db_path)
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

  it 'can read the system label db' do
    setup_test_file('/etc/xdg/labrat/labeldb.yml', @sys_db)
    LabelDb.read(dir_prefix: SANDBOX_DIR)
    expect(LabelDb[:avery5160].class).to eq(Hash)
    expect(LabelDb[:avery5160]['page-width']).to eq('8.5in')
    expect(LabelDb[:avery5160]['width']).to eq('66mm')
    expect(LabelDb[:avery5160]['height']).to eq('25mm')
    expect(LabelDb[:avery5160]['rows']).to eq(10)
    expect(LabelDb[:avery5160]['columns']).to eq(3)
  end

  it 'can read a user label db' do
    usrdb_yml = <<~YAML
      avery5160:
        width: 65mm
        height: 24mm
    YAML
    setup_test_file("/home/#{ENV['USER']}/.config/labrat/labeldb.yml", usrdb_yml)
    LabelDb.read(dir_prefix: SANDBOX_DIR)
    expect(LabelDb[:avery5160].class).to eq(Hash)
    # expect(LabelDb[:avery5160]['page-width']).to eq('8.5in')
    expect(LabelDb[:avery5160]['width']).to eq('65mm')
    expect(LabelDb[:avery5160]['height']).to eq('24mm')
  end

  it 'can read merge a system and user label db' do
    usrdb_yml = <<~YAML
      avery5160:
        width: 65mm
        height: 24mm
    YAML
    setup_test_file('/etc/xdg/labrat/labeldb.yml', @sys_db)
    setup_test_file("/home/#{ENV['USER']}/.config/labrat/labeldb.yml", usrdb_yml)
    LabelDb.read(dir_prefix: SANDBOX_DIR)
    expect(LabelDb[:avery5160].class).to eq(Hash)
    expect(LabelDb[:avery5160]['page-width']).to eq('8.5in')
    expect(LabelDb[:avery5160]['width']).to eq('65mm')
    expect(LabelDb[:avery5160]['height']).to eq('24mm')
  end

  it 'can process a --label argument' do
    usrdb_yml = <<~YAML
      avery5160:
        width: 65mm
        height: 24mm
    YAML
    setup_test_file('/etc/xdg/labrat/labeldb.yml', @sys_db)
    setup_test_file("/home/#{ENV['USER']}/.config/labrat/labeldb.yml", usrdb_yml)
    args = ['--rows=5', '--label=avery5160', '--width=60mm']
    ops = ArgParser.new.parse(args)
    expect(ops.rows).to eq(10)
    expect(ops.page_height).to be_within(EPS).of(11 * IN)
    expect(ops.width).to be_within(EPS).of(60 * MM)
  end
end
