# frozen_string_literal: true

RSpec.describe Labrat do
  it "has a version number" do
    expect(Labrat::VERSION).not_to be nil
  end

  describe 'file reading' do
    let(:lab_fname) { File.join(__dir__, 'support/spec_labels.txt') }

    it 'can read labels from a file' do
      lab_txts = Labrat.read_label_texts(lab_fname, '++')
      expect(lab_txts.size).to eq(3)
      expect(lab_txts[0]).to match(/\AFour score/)
      expect(lab_txts[1]).to match(/this continent, a\z/)
      expect(lab_txts[2]).to match(/\+\+the proposition/)
    end
  end
end
