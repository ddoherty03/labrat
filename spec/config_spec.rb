SANDBOX_DIR = 'spec/support/sandbox'

RSpec.describe Config do

  before do
    @old_pwd = Dir.pwd
    FileUtils.mkdir_p(SANDBOX_DIR)
    Dir.chdir(SANDBOX_DIR)
  end

  after do
    Dir.chdir(@old_pwd)
    FileUtils.rm_rf(SANDBOX_DIR)
  end

  # let(:cfg) { .new }
  let(:yaml_str) {
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
  }

  it 'can read a yaml string' do
    struct = YAML.load(yaml_str)
    expect(struct.keys).to include('doe')
  end

  it 'can read from a system config file' do
    sys_xdg = File.join(SANDBOX_DIR, 'etc/xdg')
    sys_labrat = File.join(SANDBOX_DIR, 'etc/xdg/labrat')
    sys_config = File.join(sys_labrat, 'config.yml')
    FileUtils.mkdir_p(sys_labrat)
    config_yml = <<~YAML
      width: 33mm
      height: 101mm
      delta_x: -4mm
      delta_y: 1cm
      nlsep: %%
      printer: seiko3
    YAML
    File.write(sys_config, config_yml)
    # binding.pry
    op = Options.new
    Config.read_config(op)
    true
  end
end
