# frozen_string_literal: true

module Labrat
  class Label
    attr_reader :texts, :ops

    def initialize(texts, ops)
      @ops = ops
      @texts = texts.map { |t| t.gsub(ops.nlsep, "\n") }
    end

    def generate
      layout = ops.landscape ? :landscape : :portrait
      # The default margin is 0.5in, way too big for labels, so it is
      # important to set these here.  The margins' designation as "top,"
      # "left," "bottom," and "right" take into account the page layout.  That
      # is, the left margin is on the left in both portrait and landscape
      # orientations.  But I want the user to be able to set the margins
      # according to the label type, independent of the orientation.  I adopt
      # the convention that the margins are named assuming a portrait
      # orientation and swap them here so that when Prawn swaps them again,
      if layout == :portrait
        tpm = ops.top_page_margin
        bpm = ops.bottom_page_margin
        lpm = ops.left_page_margin
        rpm = ops.right_page_margin
      else
        lpm = ops.top_page_margin
        rpm = ops.bottom_page_margin
        tpm = ops.left_page_margin
        bpm = ops.right_page_margin
      end

      Prawn::Document.generate(ops.out_file, page_size: [ops.page_width, ops.page_height],
                               left_margin: lpm, right_margin: rpm,
                               top_margin: tpm, bottom_margin: bpm,
                               page_layout: layout) do |pdf|
        # Define a grid with each grid box to be used for a single label.
        pdf.define_grid(rows: ops.rows, columns: ops.columns,
                        row_gutter: ops.row_gap, column_gutter: ops.column_gap)
        # if ops.verbose
        #   warn "orientation: #{layout}"
        #   warn "page_size = [#{ops.page-width}pt,#{ops.page-height}pt]"
        #   warn "[lpm, rpm] = [#{lpm}pt,#{rpm}pt]"
        #   warn "[tpm, bpm] = [#{tpm}pt,#{bpm}pt]"
        #   warn "[delta_x, delta_y] = [#{ops.delta_x}pt,#{ops.delta_y}pt]"
        #   warn "[box_x, box_y] = [#{box_x}pt,#{box_y}pt]"
        #   warn "[box_wd, box_ht] = [#{box_wd}pt,#{box_ht}pt]"
        # end
        if ops.template
          # Replace any texts with the numbers and show the grid.
          self.texts = (1..(ops.rows * ops.columns)).map(&:to_s)
          ops.font_name = 'Helvetica'
          ops.font_style = 'bold'
          ops.font_size = 16
          pdf.grid.show_all
        end
        last_k = texts.size - 1
        texts.each_with_index do |text, k|
          row, col = row_col(k + 1)
          pdf.grid(row, col).bounding_box do
            bounds = pdf.bounds
            box_wd = (bounds.right - bounds.left) - ops.left_pad - ops.right_pad
            box_ht = (bounds.top - bounds.bottom) - ops.top_pad - ops.bottom_pad
            box_x = ops.left_pad + ops.delta_x
            box_y = ops.bottom_pad + box_ht + ops.delta_y
            pdf.stroke_bounds
            pdf.font ops.font_name, style: ops.font_style.to_sym, size: ops.font_size.to_f
            pdf.text_box(text, width: box_wd, height: box_ht,
                         align: ops.h_align, valign: ops.v_align,
                         overflow: :truncate, at: [box_x, box_y])
            pdf.start_new_page if needs_new_page?(k, last_k)
          end
        end
      end
      self
    end

    def print
      cmd = ops.print_command.gsub('%p', ops.printer).gsub('%o', ops.out_file)
      system("#{cmd} &")
    end

    def view
      cmd = ops.view_command.gsub('%o', ops.out_file)
      system("#{cmd} &")
    end

    def remove
      FileUtils.rm(ops.out_file)
    end

    # Return the 0-based row and column on which the k-th (1-based) label
    # should be printed.
    def row_col(k)
      lpp = ops.rows * ops.columns
      k_on_page = (k + ops.start_label - 2) % lpp
      k_on_page.divmod(ops.columns)
    end

    # Should we emit a new page at this point?
    def needs_new_page?(k, last_k)
      return false if k == last_k
      r, c = row_col(k + 1)
      (r + 1 == ops.rows && c + 1 == ops.columns)
    end
  end
end
