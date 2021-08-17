# frozen_string_literal: true

RSpec.describe Options do
  describe 'Initialization without hash' do
    let(:ops) { Options.new }

    it 'has hard-coded default values for file folder label' do
      expect(ops.width).to be_within(EPS).of(24 * MM)
      expect(ops.height).to be_within(EPS).of(83 * MM)
      expect(ops.label).to be nil
      expect(ops.h_align).to eq(:center)
      expect(ops.v_align).to eq(:center)
    end
  end

  describe 'Initialization with hash' do
    let(:init_hash) do
      {
        width: 33 * MM,
        height: 77 * MM,
        top_margin: 1 * CM,
        junk: 'willy',
        verbose: true,
        landscape: false,
      }
    end
    let(:ops) { Options.new(**init_hash) }

    it 'attributes can be initialized with a hash to new' do
      expect(ops.width).to be_within(EPS).of(33 * MM)
      expect(ops.height).to be_within(EPS).of(77 * MM)
      expect(ops.top_margin).to be_within(EPS).of(10 * MM)
      expect(ops.label).to be nil
      expect(ops.h_align).to eq(:center)
      expect(ops.v_align).to eq(:center)
      expect(ops.landscape).to be_falsey
      expect(ops.verbose).to be_truthy
    end
  end

  describe 'Setting and reading attributes with brackets' do
    let(:ops) { Options.new }

    it 'can set an attribute with []= bracket syntax' do
      expect(ops.left_margin).to be_within(EPS).of(4.5 * MM)
      ops.left_margin = 0.7 * CM
      expect(ops.left_margin).to be_within(EPS).of(7 * MM)
    end

    it 'can read an attribute with [] bracket syntax' do
      expect(ops.left_margin).to be_within(EPS).of(4.5 * MM)
      expect(ops[:left_margin]).to be_within(EPS).of(4.5 * MM)
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
