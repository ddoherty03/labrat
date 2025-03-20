# frozen_string_literal: true

RSpec.describe Label do
  describe '#row_col' do
    describe 'Assume 1 row, 1 column' do
      it '#row_col: compute row and column of kth label with start 1' do
        ops = Options.new(rows: 1, columns: 1, start_label: 1)
        lab = Label.new([''], ops)
        expect(lab.row_col(1)).to eq([0, 0])
        expect(lab.row_col(23)).to eq([0, 0])
        expect(lab.row_col(30)).to eq([0, 0])
        expect(lab.row_col(31)).to eq([0, 0])
        expect(lab.row_col(350)).to eq([0, 0])
      end

      it '#row_col: compute row and column of kth label with start 15' do
        ops = Options.new(rows: 1, columns: 1, start_label: 15)
        lab = Label.new([''], ops)
        expect(lab.row_col(1)).to eq([0, 0])
        expect(lab.row_col(9)).to eq([0, 0])
      end
    end

    describe 'Assume 10 rows, 3 columns' do
      it '#row_col: compute row and column of kth label with start 1' do
        ops = Options.new(rows: 10, columns: 3, start_label: 1)
        lab = Label.new([''], ops)
        expect(lab.row_col(1)).to eq([0, 0])
        expect(lab.row_col(23)).to eq([7, 1])
        expect(lab.row_col(30)).to eq([9, 2])
        expect(lab.row_col(31)).to eq([0, 0])
        expect(lab.row_col(350)).to eq([6, 1])
      end

      it '#row_col: compute row and column of kth label with start 15' do
        ops = Options.new(rows: 10, columns: 3, start_label: 15)
        lab = Label.new([''], ops)
        expect(lab.row_col(1)).to eq([4, 2])
        expect(lab.row_col(9)).to eq([7, 1])
      end

      it '#row_col: compute row and column of kth label with start 30' do
        ops = Options.new(rows: 10, columns: 3, start_label: 30)
        lab = Label.new([''], ops)
        expect(lab.row_col(1)).to eq([9, 2])
        expect(lab.row_col(9)).to eq([2, 1])
      end
    end
  end
end
