# frozen_string_literal: true

RSpec.describe Options do
  describe 'Initialization without hash' do
    let(:ops) { Options.new }

    it 'has hard-coded default values for file folder label' do
      expect(ops.page_width).to be_within(EPS).of(24 * MM)
      expect(ops.page_height).to be_within(EPS).of(87 * MM)
      expect(ops.label).to be nil
      expect(ops.h_align).to eq(:center)
      expect(ops.v_align).to eq(:center)
      expect(ops.left_page_margin).to be_within(EPS).of(5 * MM)
      expect(ops.right_page_margin).to be_within(EPS).of(5 * MM)
      expect(ops.top_page_margin).to be_within(EPS).of(0 * MM)
      expect(ops.bottom_page_margin).to be_within(EPS).of(0 * MM)
      expect(ops.rows).to eq(1)
      expect(ops.columns).to eq(1)
      expect(ops.row_gap).to be_within(EPS).of(0 * MM)
      expect(ops.column_gap).to be_within(EPS).of(0 * MM)
      expect(ops.start_label).to eq(1)
      expect(ops.landscape).to eq(false)
      expect(ops.grid).to eq(false)
      expect(ops.h_align).to eq(:center)
      expect(ops.v_align).to eq(:center)
      expect(ops.left_pad).to be_within(EPS).of(4.5 * MM)
      expect(ops.right_pad).to be_within(EPS).of(4.5 * MM)
      expect(ops.top_pad).to be_within(EPS).of(0 * MM)
      expect(ops.bottom_pad).to be_within(EPS).of(0 * MM)
      expect(ops.delta_x).to be_within(EPS).of(0 * MM)
      expect(ops.delta_y).to be_within(EPS).of(0 * MM)
      expect(ops.font_name).to eq('Helvetica')
      expect(ops.font_style).to eq(:normal)
      expect(ops.in_file).to be_nil
      expect(ops.nlsep).to eq('++')
      expect(ops.copies).to eq(1)
      expect(ops.printer).to eq(ENV['PRINTER'] || 'dymo')
      expect(ops.out_file).to eq('labrat.pdf')
      expect(ops.print_command.class).to eq(String)
      expect(ops.view_command.class).to eq(String)
      expect(ops.view).to eq(false)
      expect(ops.template).to eq(false)
      expect(ops.verbose).to eq(false)
      expect(ops.msg).to be_nil
      expect(ops.font_size).to eq(12)
      expect(ops.label).to be_nil
      expect(ops.msg).to be_nil
    end
  end

  describe 'Initialization with hash' do
    let(:init_hash) do
      {
        page_width: 33 * MM,
        page_height: 77 * MM,
        top_page_margin: 1 * CM,
        junk: 'willy',
        verbose: true,
        landscape: false,
      }
    end
    let(:ops) { Options.new(**init_hash) }

    it 'attributes can be initialized with a hash to Options.new' do
      expect(ops.page_width).to be_within(EPS).of(33 * MM)
      expect(ops.page_height).to be_within(EPS).of(77 * MM)
      expect(ops.top_page_margin).to be_within(EPS).of(10 * MM)
      expect(ops.label).to be nil
      expect(ops.h_align).to eq(:center)
      expect(ops.v_align).to eq(:center)
      expect(ops.landscape).to be_falsey
      expect(ops.verbose).to be_truthy
    end
  end

  describe 'Setting and reading attributes' do
    let(:ops) { Options.new }

    it 'can set an attribute with []= bracket syntax' do
      expect(ops.left_page_margin).to be_within(EPS).of(5 * MM)
      ops[:left_page_margin] = 0.7 * CM
      expect(ops.left_page_margin).to be_within(EPS).of(7 * MM)
    end

    it 'can read an attribute with [] bracket syntax' do
      expect(ops.left_page_margin).to be_within(EPS).of(5 * MM)
      expect(ops[:left_page_margin]).to be_within(EPS).of(5 * MM)
    end

    it 'can convert itself into a Hash' do
      hsh = ops.to_hash
      expect(hsh.class).to eq(Hash)
      # NB: Options#to_hash excludes :msg key
      expect(hsh.keys.size).to be >= Options.attrs.size - 1
    end

    let(:hash) do
      {
        page_width: 33 * MM,
        page_height: 77 * MM,
        top_page_margin: 1 * CM,
        junk: 'willy',
        verbose: true,
        template: true,
      }
    end

    it 'can merge a hash into itself' do
      # Before merge, these should be the defaults
      expect(ops.page_width).to be_within(EPS).of(24 * MM)
      expect(ops.page_height).to be_within(EPS).of(87 * MM)
      expect(ops.top_page_margin).to be_within(EPS).of(0 * MM)
      expect(ops.verbose).to be_falsey
      expect(ops.template).to be_falsey
      ops.merge!(hash)
      expect(ops.page_width).to be_within(EPS).of(33 * MM)
      expect(ops.page_height).to be_within(EPS).of(77 * MM)
      expect(ops.top_page_margin).to be_within(EPS).of(10 * MM)
      expect(ops.verbose).to be_truthy
      expect(ops.template).to be_truthy
      # These are defaults
      expect(ops.top_pad).to be_within(EPS).of(0 * MM)
      expect(ops.bottom_pad).to be_within(EPS).of(0 * MM)
      expect(ops.delta_x).to be_within(EPS).of(0 * MM)
      expect(ops.delta_y).to be_within(EPS).of(0 * MM)
      expect(ops.grid).to be_falsey
      expect(ops.font_name).to eq('Helvetica')
      expect(ops.font_style).to eq(:normal)
    end
  end

  describe 'Returns its message with #to_s' do
    let(:ops) { Options.new }

    it 'returns its message with a #to_s' do
      ops.msg = 'Willy Wonka sells Chonka'
      expect(ops.to_s).to eq('Willy Wonka sells Chonka')
    end
  end
end
