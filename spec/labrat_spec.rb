# frozen_string_literal: true

RSpec.describe Labrat do
  it "has a version number" do
    expect(Labrat::VERSION).not_to be_nil
  end

  describe 'file reading' do
    let(:lab_fname) { File.join(__dir__, 'support/spec_labels.txt') }

    it 'can read label texts from a named file' do
      lab_txts = Labrat.read_label_texts(lab_fname, '~~')
      expect(lab_txts.size).to eq(3)
      expect(lab_txts[0]).to match(/\AFour score/)
      expect(lab_txts[1]).to match(/this continent, a\z/)
      expect(lab_txts[2]).to match(/~~the proposition/)
    end

    it 'can read label texts from standard input' do
      $stdin = File.open(lab_fname)
      # Using nil as a file name parameter to read_label_texts causes labels
      # to be read from standard input.
      lab_txts = Labrat.read_label_texts(nil, '~~')
      expect(lab_txts.size).to eq(3)
      expect(lab_txts[0]).to match(/\AFour score/)
      expect(lab_txts[1]).to match(/this continent, a\z/)
      expect(lab_txts[2]).to match(/~~the proposition/)
    end
  end
end
