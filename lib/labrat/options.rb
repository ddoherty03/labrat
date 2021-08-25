# frozen_string_literal: true

module Labrat
  # The Options class is a glorified Hash, a container for the options
  # settings gathered from the defaults, the config files, the command line,
  # and perhaps environment.  An Options instance can be handed off to the
  # label-printing objects to inform its formatting, printing, etc.
  class Options
    attr_accessor :label, :page_width, :page_height,
                  :left_page_margin, :right_page_margin,
                  :top_page_margin, :bottom_page_margin,
                  :rows, :columns, :row_gap, :column_gap, :landscape,
                  :start_label,
                  :width, :height, :h_align, :v_align,
                  :left_margin, :right_margin, :top_margin, :bottom_margin,
                  :delta_x, :delta_y,
                  :font_name, :font_style, :font_size,
                  :file, :nlsep,
                  :printer, :out_file, :print_command, :view_command, :view,
                  :verbose, :msg

    # Initialize with an optional hash of default values for the attributes.
    def initialize(**init)
      self.label = init[:label] || nil
      # Per-page attributes
      self.page_width = init[:page_width] || 24.mm
      self.page_height = init[:page_height] || 83.mm
      self.left_page_margin = init[:left_page_margin] || 0.mm
      self.right_page_margin = init[:right_page_margin] || 0.mm
      self.top_page_margin = init[:top_page_margin] ||  0.mm
      self.bottom_page_margin = init[:bottom_page_margin] || 0.mm
      self.rows = init[:rows] || 1
      self.columns = init[:columns] || 1
      self.row_gap = init[:row_gap] || 0.mm
      self.column_gap = init[:column_gap] || 0.mm
      self.start_label = init[:start_label] || 1
      self.landscape = init.fetch(:landscape, true)
      # Per-label attributes
      self.width = init[:width] || 24.mm
      self.height = init[:height] || 83.mm
      self.h_align = init[:h_align]&.to_sym || :center
      self.v_align = init[:v_align]&.to_sym || :center
      self.left_margin = init[:left_margin] || 4.5.mm
      self.right_margin = init[:right_margin] || 4.5.mm
      self.top_margin = init[:top_margin] ||  0
      self.bottom_margin = init[:bottom_margin] || 0
      self.delta_x = init[:delta_x] ||  0
      self.delta_y = init[:delta_y] ||  0
      self.font_name = init[:font_name] || 'Helvetica'
      self.font_style = init[:font_style]&.to_sym || :normal
      self.font_size = init[:font_size] ||  12
      # Input attributes
      self.file = init[:file] || nil
      self.nlsep = init[:nlsep] || '++'
      # Output attributes
      self.printer = init[:printer] || 'dymo'
      self.out_file = init[:out_file] || 'label.pdf'
      self.print_command = init[:print_command] || 'lpr -P %p %o'
      self.view_command = init[:view_command] || 'zathura %o'
      self.view = init.fetch(:view, false)
      self.verbose = init.fetch(:verbose, false)
      self.msg = init[:msg] || nil
    end

    # Return any string in msg, e.g., the usage help or error.
    def to_s
      msg
    end

    # Allow hash-like assignment to attributes.  This allows an Options object
    # to be used, for example, in the OptionParser#parse :into parameter.
    def []=(att, val)
      send("#{att}=", val)
    end

    # Allow hash-like access to attributes.  This allows an Options object
    # to be used, for example, in the OptionParser#parse :into parameter.
    def [](att)
      send("#{att}")
    end

    # Return a hash of the values in this Options object.
    def to_hash
      {
        label: label,
        page_width: page_width,
        page_height: page_height,
        left_page_margin: left_page_margin,
        right_page_margin: right_page_margin,
        top_page_margin: top_page_margin,
        bottom_page_margin: bottom_page_margin,
        rows: rows,
        columns: columns,
        row_gap: row_gap,
        column_gap: column_gap,
        start_label: start_label,
        landscape: landscape,
        # Per-label attributes
        width: width,
        height: height,
        h_align: h_align,
        v_align: v_align,
        left_margin: left_margin,
        right_margin: right_margin,
        top_margin: top_margin,
        bottom_margin: bottom_margin,
        delta_x: delta_x,
        delta_y: delta_y,
        font_name: font_name,
        font_style: font_style,
        font_size: font_size,
        # Input attributes
        file: file,
        nlsep: nlsep,
        # Output attributes
        printer: printer,
        out_file: out_file,
        print_command: print_command,
        view_command: view_command,
        view: view,
        verbose: verbose,
        msg: msg,
      }
    end

    # Update the fields of this Option instance by merging in the values in
    # hsh into self.  Ignore any keys in hsh not corresponding to a setter for
    # an Options object.
    def merge!(hsh)
      # Convert any separator hyphens in the hash keys to underscores
      hsh = hsh.to_hash.transform_keys { |key| key.to_s.gsub('-', '_').to_sym }
      new_hash = to_hash.merge(hsh)
      new_hash.each_pair do |k, val|
        setter = "#{k}=".to_sym
        next unless respond_to?(setter)

        send(setter, val)
      end
      self
    end
  end
end
