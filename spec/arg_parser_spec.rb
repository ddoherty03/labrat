MM = 2.83464566929
IN = 72.0
EPS = 0.000001

RSpec.describe ArgParser do
  let(:ap) { ArgParser.new }

  it 'can initialize to an Options object' do
    expect(ap.parse([])).to be_instance_of(Options)
  end

  it 'can parse default options with no args' do
    op = ap.parse([])
    expect(op).to be_instance_of(Options)
    expect(op.label_width).to be_within(EPS).of(28 * MM)
    expect(op.label_height).to be_within(EPS).of(88 * MM)
    expect(op.delta_x).to be_within(EPS).of(0 * MM)
    expect(op.delta_y).to be_within(EPS).of(0 * MM)
    expect(op.printer_name).to eq('dymo')
    expect(op.nl_marker).to eq('++')
    expect(op.in_file).to be_nil
  end

  it 'can produce help' do
    help = ap.parse(['--help']).msg
    expect(help).to include('--width')
    expect(help).to include('--height')
    expect(help).to include('--delta_x')
    expect(help).to include('--delta_y')
    expect(help).to include('--printer')
    expect(help).to include('--nlsep')
    expect(help).to include('--file')
    expect(help).to include('--landscape')
    expect(help).to include('--portrait')
    expect(help).to include('--[no-]verbose')
  end

  it 'can produce version' do
    expect(ap.parse(['--version']).msg).to match(/\A[0-9.]+\z/)
  end

  it 'produces help on bad option' do
    bad_option = '--lsflkwroi'
    err_msg = ap.parse([bad_option]).msg
    expect(err_msg).to include('Error: invalid option')
    expect(err_msg).to include(bad_option)
  end

  it 'can set the dimensions of the label' do
    ops = ap.parse(['--width=4cm', '--height', '60mm'])
    expect(ops.label_width).to be_within(EPS).of(40 * MM)
    expect(ops.label_height).to be_within(EPS).of(60 * MM)
    ops = ap.parse(['-w', '0.5in', '-h', '3.4375in'])
    expect(ops.label_width).to be_within(EPS).of(0.5 * IN)
    expect(ops.label_height).to be_within(EPS).of(3.4375 * IN)
  end
end
