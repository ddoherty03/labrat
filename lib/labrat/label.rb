# frozen_string_literal: true

module Labrat
  class Label
    attr_reader :ops
    attr_accessor :texts

    def initialize(texts, ops)
      @ops = ops
      unless @ops.nl_sep.nil? || @ops.nl_sep == ''
        @texts = texts.map { |t| t.gsub(ops.nl_sep, "\n") }
      end
      if @ops.copies > 1
        duped_texts = []
        @texts.each { |t| @ops.copies.times { duped_texts << t } }
        @texts = duped_texts
      end
    end

    def generate
      # The default margin is 0.5in on all sides, way too big for labels, so
      # it is important to set these here.  The margins' designation as "top,"
      # "left," "bottom," and "right" take into account the page layout.  That
      # is, the left margin is on the left in both portrait and landscape
      # orientations.  But I want the user to be able to set the margins
      # according to the label type, independent of the orientation.  I adopt
      # the convention that the margins are named assuming a portrait
      # orientation and swap them here so that when Prawn swaps them again,
      # they come out correct.
      layout = ops.landscape ? :landscape : :portrait
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
      out_file = File.expand_path(ops.out_file)
      Prawn::Document.generate(
        out_file,
        page_size: [ops.page_width, ops.page_height],
                                       left_margin: lpm,
        right_margin: rpm,
                                       top_margin: tpm,
        bottom_margin: bpm,
                                       page_layout: layout,
      ) do |pdf|
        # Define a grid with each grid box to be used for a single label.
        pdf.define_grid(
          rows: ops.rows,
          columns: ops.columns,
          row_gutter: ops.row_gap,
          column_gutter: ops.column_gap,
        )
        if ops.verbose
          warn "Page dimensions:"
          warn "  [pg_wd, pg_ht] = [#{ops.page_width.round(2)}pt,#{ops.page_height.round(2)}pt]"
          warn "  orientation: #{layout}"
          warn "  [rows, columns] = [#{ops.rows},#{ops.columns}]"
          warn "  [lpm, rpm] = [#{lpm.round(2)}pt,#{rpm.round(2)}pt]"
          warn "  [tpm, bpm] = [#{tpm.round(2)}pt,#{bpm.round(2)}pt]"
          warn ""
        end
        if ops.template
          # Replace any texts with the numbers, the name of the label (and alias) and show the grid.
          lab_text = ops.raw_label || ops.label
          if ops.label != ops.raw_label
            lab_text += "\n(#{ops.label})"
          end
          self.texts = (1..(ops.rows * ops.columns)).map { |n| "#{n}\n#{lab_text}" }
          ops.font_name = 'Helvetica'
          ops.font_style = 'bold'
          ops.font_size = 11
          pdf.grid.show_all
        end
        raise EmptyLabelError, "Empty label" if waste_of_labels?

        last_k = texts.size - 1
        lab_dims_reported = false
        texts.each_with_index do |text, k|
          row, col = row_col(k + 1)
          pdf.grid(row, col).bounding_box do
            bounds = pdf.bounds
            pdf.stroke_bounds if ops.grid
            box_wd = (bounds.right - bounds.left) - ops.left_pad - ops.right_pad
            box_ht = (bounds.top - bounds.bottom) - ops.top_pad - ops.bottom_pad
            box_x = ops.left_pad + ops.delta_x
            box_y = ops.bottom_pad + box_ht + ops.delta_y
            pdf.font ops.font_name, style: ops.font_style, size: ops.font_size.to_f
            pdf.text_box(
              text,
              width: box_wd,
              height: box_ht,
                                       align: ops.h_align,
              valign: ops.v_align,
                                       overflow: :truncate,
              at: [box_x, box_y],
            )
            if ops.verbose && !lab_dims_reported
              warn "Label text box dimensions:"
              warn "  [box_wd, box_ht] = [#{box_wd.round(2)}pt,#{box_ht.round(2)}pt]"
              warn "  [box_x, box_y] = [#{box_x.round(2)}pt,#{box_y.round(2)}pt]"
              warn "  [delta_x, delta_y] = [#{ops.delta_x.round(2)}pt,#{ops.delta_y.round(2)}pt]"
              warn ''
              lab_dims_reported = true
            end
            if ops.verbose
              warn "Label ##{(k % lpp) + 1} on page #{page_num(k)} at row #{row + 1}, column #{col + 1}:"
              warn '-------------------'
              warn text
              warn '-------------------'
              warn ''
            end
            pdf.start_new_page if needs_new_page?(k, last_k)
          end
        end
      end
      self
    end

    def print
      cmd = ops.print_command.gsub('%p', ops.printer).gsub('%o', ops.out_file)
      if ops.verbose
        warn "Printing with:"
        warn "  #{cmd} &"
      end
      system("#{cmd} &")
    end

    def view
      cmd = ops.view_command.gsub('%o', ops.out_file)
      if ops.verbose
        warn "Viewing with:"
        warn "  #{cmd} &"
      end
      system("#{cmd} &")
    end

    def remove
      FileUtils.rm(ops.out_file)
    end

    # Labels per page
    def lpp
      ops.rows * ops.columns
    end

    # Page number of the kth label
    def page_num(k)
      k.divmod(lpp)[0] + 1
    end

    # Return the 0-based row and column within a page on which the k-th
    # (1-based) label should be printed.
    def row_col(k)
      k_on_page = (k + ops.start_label - 2) % lpp
      k_on_page.divmod(ops.columns)
    end

    # Should we emit a new page at this point?
    def needs_new_page?(k, last_k)
      return false if k == last_k

      r, c = row_col(k + 1)
      r + 1 == ops.rows && c + 1 == ops.columns
    end

    # Would we just be printing blank labels?
    def waste_of_labels?
      (texts.nil? || texts.empty? || texts.all?(&:blank?)) &&
        !ops.view
    end
  end
end
