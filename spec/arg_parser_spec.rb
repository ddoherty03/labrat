RSpec.describe ArgParser do
  let(:ap) { ArgParser.new }

  describe 'input and output hashes and Options objects' do
    it 'returns an Options object' do
      expect(ap.parse([])).to be_instance_of(Options)
    end

    it 'can parse default options with no args' do
      op = ap.parse([])
      expect(op).to be_instance_of(Options)
      expect(op.page_width).to be_within(EPS).of(24 * MM)
      expect(op.page_height).to be_within(EPS).of(87 * MM)
      expect(op.left_page_margin).to be_within(EPS).of(5 * MM)
      expect(op.right_page_margin).to be_within(EPS).of(5 * MM)
      expect(op.top_page_margin).to be_within(EPS).of(0 * MM)
      expect(op.bottom_page_margin).to be_within(EPS).of(0 * MM)
      expect(op.rows).to eq(1)
      expect(op.columns).to eq(1)
      expect(op.row_gap).to be_within(EPS).of(0 * MM)
      expect(op.column_gap).to be_within(EPS).of(0 * MM)
      expect(op.start_label).to eq(1)
      expect(op.landscape).to be(true)
      expect(op.h_align).to eq(:center)
      expect(op.v_align).to eq(:center)
      expect(op.left_pad).to be_within(EPS).of(4.5 * MM)
      expect(op.right_pad).to be_within(EPS).of(4.5 * MM)
      expect(op.top_pad).to be_within(EPS).of(0 * MM)
      expect(op.bottom_pad).to be_within(EPS).of(0 * MM)
      expect(op.delta_x).to be_within(EPS).of(0 * MM)
      expect(op.delta_y).to be_within(EPS).of(0 * MM)
      expect(op.font_name).to eq('Helvetica')
      expect(op.font_style).to eq(:normal)
      expect(op.font_size).to eq(12)
      expect(op.file).to be_nil
      expect(op.nlsep).to eq('++')
      expect(op.printer).to eq('dymo')
      expect(op.out_file.class).to eq(String)
      expect(op.print_command.class).to eq(String)
      expect(op.view_command.class).to eq(String)
      expect(op.view).to be(false)
      expect(op.template).to be(false)
      expect(op.verbose).to be(false)
      expect(op.msg).to be_nil
    end

    it 'can take an in initial hash to merge into' do
      start_hash = {
        page_width: 30 * MM,
        page_height: 75 * MM,
        v_align: :top,
        printer: 'seiko',
        nlsep: '__',
      }
      op = ap.parse(['-h 88mm', '--nlsep=##'], start_hash)
      expect(op.page_width).to be_within(EPS).of(30 * MM)
      expect(op.right_page_margin).to be_within(EPS).of(5 * MM)
      expect(op.v_align).to eq(:top)
      expect(op.printer).to eq('seiko')
      expect(op.page_height).to be_within(EPS).of(88 * MM)
      expect(op.nlsep).to eq('##')
    end

    it 'can take an in initial Options instance to merge into' do
      start_op = Options.new(
        page_width: 30 * MM,
        page_height: 75 * MM,
        v_align: :top,
        printer: 'seiko',
        nlsep: '__',
      )
      op = ap.parse(['-h 88mm', '--nlsep=##'], start_op)
      expect(op.page_width).to be_within(EPS).of(30 * MM)
      expect(op.right_pad).to be_within(EPS).of(4.5 * MM)
      expect(op.v_align).to eq(:top)
      expect(op.printer).to eq('seiko')
      expect(op.page_height).to be_within(EPS).of(88 * MM)
      expect(op.nlsep).to eq('##')
    end
  end

  describe 'handling of specific options' do
    it 'can produce help' do
      help = ap.parse(['--help']).msg
      expect(help).to include('--label')
      expect(help).to include('--page-width')
      expect(help).to include('--page-height')
      expect(help).to include('--left-page-margin')
      expect(help).to include('--right-page-margin')
      expect(help).to include('--top-page-margin')
      expect(help).to include('--bottom-page-margin')
      expect(help).to include('--rows')
      expect(help).to include('--columns')
      expect(help).to include('--row-gap')
      expect(help).to include('--column-gap')
      expect(help).to include('--[no-]landscape')
      expect(help).to include('--start-label')
      expect(help).to include('--list-labels')
      expect(help).to include('--h-align')
      expect(help).to include('--v-align')
      expect(help).to include('--left-pad')
      expect(help).to include('--right-pad')
      expect(help).to include('--top-pad')
      expect(help).to include('--bottom-pad')
      expect(help).to include('--delta-x')
      expect(help).to include('--delta-y')
      expect(help).to include('--font-name')
      expect(help).to include('--font-style')
      expect(help).to include('--font-size')
      expect(help).to include('--file')
      expect(help).to include('--nlsep')
      expect(help).to include('--printer')
      expect(help).to include('--out-file')
      expect(help).to include('--print-command')
      expect(help).to include('--view-command')
      expect(help).to include('--[no-]template')
      expect(help).to include('--[no-]view')
      expect(help).to include('--[no-]verbose')
    end

    it 'can produce version' do
      expect(ap.parse(['--version']).msg).to match(/[0-9.]+/)
    end

    it 'produces help on invalid option' do
      bad_option = '--lsflkwroi'
      err_msg = ap.parse([bad_option]).msg
      expect(err_msg).to include('Error: invalid option')
      expect(err_msg).to include(bad_option)
    end

    it 'produces help on missing option arg' do
      option = '--delta_x'
      err_msg = ap.parse([option]).msg
      expect(err_msg).to include('Error: missing argument:')
      expect(err_msg).to include(option)
    end

    it 'can set the dimensions of the page' do
      # Points
      ops = ap.parse(['-w', '44', '-h', '180.5'])
      expect(ops.page_width).to be_within(EPS).of(44.0)
      expect(ops.page_height).to be_within(EPS).of(180.5)
      # Long options
      ops = ap.parse(['--page-width=4cm', '--page-height', '60mm'])
      expect(ops.page_width).to be_within(EPS).of(40 * MM)
      expect(ops.page_height).to be_within(EPS).of(60 * MM)
      # Short options
      ops = ap.parse(['-w', '0.5in', '-h', '3.4375in'])
      expect(ops.page_width).to be_within(EPS).of(0.5 * IN)
      expect(ops.page_height).to be_within(EPS).of(3.4375 * IN)
    end

    it 'can set the name of a label' do
      ops = ap.parse(['--label=dymo30327'])
      expect(ops.label).to eq('dymo30327')
    end

    it 'can set the offset dimensions' do
      ops = ap.parse(['--delta_x=0.5cm', '--delta_y', '6mm'])
      expect(ops.delta_x).to be_within(EPS).of(5 * MM)
      expect(ops.delta_y).to be_within(EPS).of(6 * MM)
      ops = ap.parse(['-x', '0.5in', '-y', '3.4375in'])
      expect(ops.delta_x).to be_within(EPS).of(0.5 * IN)
      expect(ops.delta_y).to be_within(EPS).of(3.4375 * IN)
    end

    it 'can convert certain units' do
      # pt, mm, cm, dm, m, in, ft, yd
      units = %i[pt mm cm dm m in ft yd]
      units.each do |unit|
        ops = ap.parse(["--delta_x=5#{unit}"])
        expect(ops.delta_x).to be_kind_of(Numeric)
      end
      units = %i[mi furlongs]
      units.each do |unit|
        expect { ap.parse(["--delta_x=5#{unit}"]) }.to raise_exception(Labrat::DimensionError)
      end
    end

    it 'can set the printer name' do
      ops = ap.parse(['--printer=epson55'])
      expect(ops.printer).to eq('epson55')
    end

    it 'can set the printer name' do
      ops = ap.parse(['--printer=epson55'])
      expect(ops.printer).to eq('epson55')
    end

    it 'can set the new-line marker' do
      ops = ap.parse(['--nlsep=&&'])
      expect(ops.nlsep).to eq('&&')
      ops = ap.parse(['-n', '&&'])
      expect(ops.nlsep).to eq('&&')
    end

    it 'can set an optional input file' do
      ops = ap.parse(['-f junk.lab'])
      expect(ops.file).to eq('junk.lab')
      ops = ap.parse(['--file junk.lab'])
      expect(ops.file).to eq('junk.lab')
      ops = ap.parse(['--file', '  file with some spaces  	'])
      expect(ops.file).to eq('file with some spaces')
    end

    it 'can set an optional output PDF file' do
      ops = ap.parse(['-ojunk'])
      expect(ops.out_file).to eq('junk.pdf')
      ops = ap.parse(['--out-file junk'])
      expect(ops.out_file).to eq('junk.pdf')
      ops = ap.parse(['--out-file=junk.PDF'])
      expect(ops.out_file).to eq('junk.PDF')
      ops = ap.parse(['--out-file', '  file with some spaces  	'])
      expect(ops.out_file).to eq('file with some spaces.pdf')
    end

    it 'can set an optional print command' do
      ops = ap.parse(["-%lppr -P %p %o"])
      expect(ops.print_command).to eq('lppr -P %p %o')
      ops = ap.parse(["--print-command=lppr -P %p %o"])
      expect(ops.print_command).to eq('lppr -P %p %o')
    end

    it 'can set an optional view command' do
      ops = ap.parse(["-:snapview %o"])
      expect(ops.view_command).to eq('snapview %o')
      ops = ap.parse(["--view-command=snapview %o"])
      expect(ops.view_command).to eq('snapview %o')
    end

    it 'can ask to view rather than print' do
      ops = ap.parse(["-V"])
      expect(ops.view).to be true
      ops = ap.parse(["--view"])
      expect(ops.view).to be true
      ops = ap.parse(["--no-view"])
      expect(ops.view).to be false
    end

    it 'can set orientation' do
      ops = ap.parse(['-L'])
      expect(ops.landscape).to be true
      ops = ap.parse(['--landscape'])
      expect(ops.landscape).to be true
      ops = ap.parse(['--no-landscape'])
      expect(ops.landscape).to be false
      # Portrait is, essentially, --no-landacape
      ops = ap.parse(['-P'])
      expect(ops.landscape).to be false
      ops = ap.parse(['--portrait'])
      expect(ops.landscape).to be false
      ops = ap.parse(['--no-portrait'])
      expect(ops.landscape).to be true
    end

    it 'can set verbose' do
      ops = ap.parse([])
      expect(ops.verbose).to be false
      ops = ap.parse(['-v'])
      expect(ops.verbose).to be true
      ops = ap.parse(['--verbose'])
      expect(ops.verbose).to be true
      ops = ap.parse(['--no-verbose'])
      expect(ops.verbose).to be false
    end
  end
end
