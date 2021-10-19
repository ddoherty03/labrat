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
                  :start_label, :grid,
                  :h_align, :v_align,
                  :left_pad, :right_pad, :top_pad, :bottom_pad,
                  :delta_x, :delta_y,
                  :font_name, :font_style, :font_size,
                  :in_file, :nl_sep, :copies,
                  :printer, :out_file, :print_command, :view_command, :view,
                  :template, :verbose, :msg

    # Initialize with an optional hash of default values for the attributes.
    def initialize(**init)
      self.label = init[:label] || nil
      # Per-page attributes
      self.page_width = init[:page_width] || 24.mm
      self.page_height = init[:page_height] || 87.mm
      self.left_page_margin = init[:left_page_margin] || 5.mm
      self.right_page_margin = init[:right_page_margin] || 5.mm
      self.top_page_margin = init[:top_page_margin] ||  0.mm
      self.bottom_page_margin = init[:bottom_page_margin] || 0.mm
      self.rows = init[:rows] || 1
      self.columns = init[:columns] || 1
      self.row_gap = init[:row_gap] || 0.mm
      self.column_gap = init[:column_gap] || 0.mm
      self.start_label = init[:start_label] || 1
      self.landscape = init.fetch(:landscape, false)
      # Per-label attributes
      self.h_align = init[:h_align]&.to_sym || :center
      self.v_align = init[:v_align]&.to_sym || :center
      self.left_pad = init[:left_pad] || 4.5.mm
      self.right_pad = init[:right_pad] || 4.5.mm
      self.top_pad = init[:top_pad] ||  0
      self.bottom_pad = init[:bottom_pad] || 0
      self.delta_x = init[:delta_x] ||  0
      self.delta_y = init[:delta_y] ||  0
      self.font_name = init[:font_name] || 'Helvetica'
      self.font_style = init[:font_style]&.to_sym || :normal
      self.font_size = init[:font_size] || 12
      # Input attributes
      self.in_file = init[:in_file] || nil
      self.nl_sep = init[:nl_sep] || '++'
      self.copies = init[:copies] || 1
      # Output attributes
      self.printer = init[:printer] || ENV['LABRAT_PRINTER'] || ENV['PRINTER'] || 'dymo'
      self.out_file = init[:out_file] || 'labrat.pdf'
      self.print_command = init[:print_command] || 'lpr -P %p %o'
      self.view_command = init[:view_command] || 'qpdfview --unique --instance labrat %o'
      self.view = init.fetch(:view, false)
      self.template = init.fetch(:landscape, false)
      self.grid = init.fetch(:gid, false)
      self.verbose = init.fetch(:verbose, false)
      self.msg = init[:msg] || nil
    end

    # High-level setting of options from config files, and given command-line
    # args.
    def self.set_options(args, verbose: false)
      # Default, built-in config; set verbose to param.
      default_config = Labrat::Options.new(verbose: verbose).to_hash
      default_config.report("Default settings") if verbose

      # Config files
      file_config = Labrat::Config.read('labrat', verbose: verbose)
      file_config.report("Settings from merged config files") if verbose
      file_options = Labrat::ArgParser.new.parse(file_config, prior: default_config, verbose: verbose)

      # Command-line
      if verbose
        warn "Command-line:"
        args.each do |arg|
          warn arg.to_s
        end
        warn ""
      end
      Labrat::ArgParser.new.parse(args, prior: file_options, verbose: verbose)
    end

    # Return any string in msg, e.g., the usage help or error.
    def to_s
      msg
    end

    # Allow hash-like assignment to attributes.  This allows an Options object
    # to be used, for example, in the OptionParser#parse :into parameter.
    def []=(att, val)
      att = att.to_s.gsub('-', '_')
      send("#{att}=", val)
    end

    # Allow hash-like access to attributes.  This allows an Options object
    # to be used, for example, in the OptionParser#parse :into parameter.
    def [](att)
      att = att.to_s.gsub('-', '_')
      send(att.to_s)
    end

    # For testing, return an Array of the attributes.
    def self.attrs
      instance_methods(false).grep(/\A[a-z_]+=\Z/)
        .map { |a| a.to_s.sub(/=\z/, '') }
    end

    # For testing, return an Array of the flags-form of the attributes, i.e.,
    # with the underscores, _, replaced with hyphens.
    def self.flags
      attrs.map { |a| a.gsub('_', '-') }
    end

    # Return a hash of the values in this Options object.  This is the
    # canonical form of a Hash for Labrat, i.e., symbolic keys with any
    # hyphens translated into underscores.  Don't include the msg attribute.
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
        grid: grid,
        start_label: start_label,
        landscape: landscape,
        # Per-label attributes
        h_align: h_align,
        v_align: v_align,
        left_pad: left_pad,
        right_pad: right_pad,
        top_pad: top_pad,
        bottom_pad: bottom_pad,
        delta_x: delta_x,
        delta_y: delta_y,
        font_name: font_name,
        font_style: font_style,
        font_size: font_size,
        # Input attributes
        in_file: in_file,
        nl_sep: nl_sep,
        copies: copies,
        # Output attributes
        printer: printer,
        out_file: out_file,
        print_command: print_command,
        view_command: view_command,
        view: view,
        template: template,
        verbose: verbose,
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
