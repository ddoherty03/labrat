# frozen_string_literal: true

RSpec.describe LabelDb do
  before :each do
    # Save these, since they're not specific to this app.
    @xdg_config_dirs = ENV['XDG_CONFIG_DIRS']
    @xdg_config_home = ENV['XDG_CONFIG_HOME']
    @sys_db_path = File.join(__dir__, '../lib/config_files/labeldb.yml')
    @sys_db = File.read(@sys_db_path)
    @user_db_path = File.join(__dir__, '../lib/config_files/labeldb_usr.yml')
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

  it 'can read the system label db' do
    setup_test_file('/etc/xdg/labrat/labeldb.yml', @sys_db)
    LabelDb.read(dir_prefix: SANDBOX_DIR)
    expect(LabelDb[:avery5160].class).to eq(Hash)
    expect(LabelDb[:avery5160][:page_width]).to eq('8.5in')
    expect(LabelDb[:avery5160][:page_height]).to eq('11in')
    expect(LabelDb[:avery5160][:rows]).to eq(10)
    expect(LabelDb[:avery5160][:columns]).to eq(3)
  end

  it 'can read a user label db' do
    usrdb_yml = <<~YAML
      avery5160:
        page-width: 65mm
        page-height: 24mm
    YAML
    setup_test_file("/home/#{ENV['USER']}/.config/labrat/labeldb.yml", usrdb_yml)
    LabelDb.read(dir_prefix: SANDBOX_DIR)
    expect(LabelDb[:avery5160].class).to eq(Hash)
    # expect(LabelDb[:avery5160]['page-width']).to eq('8.5in')
    expect(LabelDb[:avery5160][:page_width]).to eq('65mm')
    expect(LabelDb[:avery5160][:page_height]).to eq('24mm')
  end

  it 'can read merge a system and user label db' do
    usrdb_yml = <<~YAML
      avery5160:
        page-width: 65mm
        page-height: 24mm
    YAML
    setup_test_file('/etc/xdg/labrat/labeldb.yml', @sys_db)
    setup_test_file("/home/#{ENV['USER']}/.config/labrat/labeldb.yml", usrdb_yml)
    LabelDb.read(dir_prefix: SANDBOX_DIR)
    expect(LabelDb[:avery5160].class).to eq(Hash)
    expect(LabelDb[:avery5160][:page_width]).to eq('65mm')
    expect(LabelDb[:avery5160][:page_height]).to eq('24mm')
  end

  it 'can process a --label argument' do
    # NOTE: from the system db
    # avery5160:
    #   page-width: 8.5in
    #   page-height: 11in
    #   rows: 10
    #   columns: 3
    #   top-page-margin: 13mm
    #   bottom-page-margin: 12mm
    #   left-page-margin: 5mm
    #   right-page-margin: 5mm
    #   row-gap: 0mm
    #   column-gap: 3mm
    #   landscape: false
    usrdb_yml = <<~YAML
      avery5160:
        page-width: 65mm
        page-height: 24mm
    YAML
    setup_test_file('/etc/xdg/labrat/labeldb.yml', @sys_db)
    setup_test_file("/home/#{ENV['USER']}/.config/labrat/labeldb.yml", usrdb_yml)
    args = ['--rows=5', '--label=avery5160', '--page-width=60mm']
    prior = LabelDb.read(dir_prefix: SANDBOX_DIR)
    ops = ArgParser.new.parse(args, prior:)
    # Note that --label overrides --row as it appears later.
    expect(ops.rows).to eq(10)
    expect(ops.page_height).to be_within(EPS).of(24 * MM)
    expect(ops.page_width).to be_within(EPS).of(60 * MM)
  end
end
