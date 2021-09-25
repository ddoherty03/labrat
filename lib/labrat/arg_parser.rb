# frozen_string_literal: true

module Labrat
  # An ArgParser object implements parsing of command-line arguments and
  # gathering them into an Options object.  By using the from_hash method, you
  # can get an ArgParser object to also treat a Hash as if it were a set of
  # command-line arguments so that config files, converted to a Hash can also
  # be used with an ArgParser.
  class ArgParser
    attr_reader :parser, :options

    def initialize
      @options = Labrat::Options.new
      @parser = OptionParser.new
      @parser.summary_width = 30
      define_options
    end

    # Parse and set the options object to reflect the values of the given
    # args, after merging in any prior settings into options.  Return the
    # resulting options instance.  The args argument can be either a Hash or,
    # as usual, an Array of Strings from the command-line.x  Throw an exception
    # for errors encountered parsing the args.
    def parse(args, prior: {}, verbose: false)
      options.msg = nil
      options.verbose = verbose
      options.merge!(prior)
      case args
      when Hash
        parser.parse!(args.optionize)
      when Array
        parser.parse!(args)
      else
        raise "ArgParser cannot parse args of class '#{args.class}'"
      end
      options
    rescue OptionParser::ParseError => e
      options.msg = "Error: #{e}\n\nTry `labrat --help` for usage."
      raise Labrat::OptionError, options.msg
    end

    private

    # Define the OptionParser rules for acceptable options in Labrat.
    def define_options
      parser.banner = "Usage: labrat [options] <label-text>"
      parser.separator ""
      parser.separator "Print or view (with -V) a label with the given <label-text>."
      parser.separator "All non-option arguments are used for the label text with a special"
      parser.separator "marker ('++' by default, see --nlsep) indicating a line-break."
      parser.separator ""
      parser.separator "Below, NUM indicates an integer, DIM, indicates a linear dimension,"
      parser.separator "valid DIM units are: pt, mm, cm, dm, m, in, ft, yd."
      parser.separator "A DIM with no units assumes pt (points)."
      parser.separator ""
      parser.separator "Meta options:"
      label_name_option
      list_labels_option

      parser.separator ""
      parser.separator "Page setup options:"
      page_dimension_options
      page_margin_options

      parser.separator ""
      parser.separator "Label setup options:"
      landscape_option
      portrait_option
      padding_options
      align_options
      font_options
      delta_options

      parser.separator ""
      parser.separator "Processing options:"
      start_label_option
      nl_sep_option
      in_file_option
      out_file_option
      printer_name_option
      command_options
      view_option
      grid_option
      template_option
      verbose_option

      parser.separator ""
      parser.separator "Common options:"
      # Normally, options.msg is nil.  If it is set to a string, we want
      # the main program to print the string and exit.
      options.msg = nil
      parser.on_tail("--help", "Show this message") do
        # NB: parser.to_s returns the usage message.
        options.msg = parser.to_s
      end
      # Another typical switch to print the version.
      parser.on_tail("--version", "Show version") do
        options.msg = "labrat version #{VERSION}"
      end
    end

    # Use the facilities of 'prawn/measurement_extensions' to convert
    # dimensions given in pt, mm, cm, dm, m, in, ft, yd into Adobe points, or
    # "big points" in TeX jargon.
    def parse_dimension(str, where = '')
      unless (match = str.match(/\A\s*(?<measure>[-+]?[0-9.]+)\s*(?<unit>[A-Za-z]*)\s*\z/))
        raise Labrat::DimensionError, "illegal #{where} dimension: '#{str}'"
      end

      if match[:unit].empty?
        match[:measure].to_f
      else
        meas = match[:measure].to_f
        u_meth = match[:unit].to_sym
        unless meas.respond_to?(u_meth)
          msg = "Error: unknown #{where} unit: '#{match[:unit]}'\n"\
          "  valid units are: pt, mm, cm, dm, m, in, ft, yd"
          raise Labrat::DimensionError, msg
        end
        points = meas.send(u_meth)
        warn "  ::#{where} <- #{str} (#{points}pt)::" if options.verbose
        points
      end
    end

    # Define options for specifying the dimensions of a page of labels to be
    # printed on.
    def page_dimension_options
      # Specifies an optional option argument
      parser.on("-wDIM", "--page-width=DIM",
                "Horizontal dimension of a page of labels as it comes out of the printer") do |wd|
        options.page_width = parse_dimension(wd, 'page-width')
      end
      parser.on("-hDIM", "--page-height=DIM",
                "Vertical dimension of a page of labels as it comes out of the printer") do |ht|
        options.page_height = parse_dimension(ht, 'page-height')
      end
      parser.on("-RNUM", "--rows=NUM", Integer,
                "Number of rows of labels on a page") do |n|
        options.rows = n
        warn "  ::rows <- #{n}::" if options.verbose
      end
      parser.on("-CNUM", "--columns=NUM", Integer,
                "Number of columns of labels on a page") do |n|
        options.columns = n
        warn "  ::columns <- #{n}::" if options.verbose
      end
      parser.on("--row-gap=DIM",
                "Vertical space between rows of labels on a page") do |gap|
        options.row_gap = parse_dimension(gap, 'row-gap')
      end
      parser.on("--column-gap=DIM",
                "Column gap:",
                "Horizontal space between columns of labels on a page") do |gap|
        options.column_gap = parse_dimension(gap, 'column-gap')
      end
    end

    # Set the page margins for printing on a page of labels.  Left, right,
    # top, and bottom are named assuming a portrait orientation, that is the
    # orientation of the page as it comes out of the printer.
    def page_margin_options
      parser.on("--right-page-margin=DIM",
                "Distance from right side of page (in portrait) to print area") do |x|
        options.right_page_margin = parse_dimension(x, 'right-page-margin')
      end
      parser.on("--left-page-margin=DIM",
                "Distance from left side of page (in portrait) to print area") do |x|
        options.left_page_margin = parse_dimension(x, 'left-page-margin')
      end
      parser.on("--top-page-margin=DIM",
                "Distance from top side of page (in portrait) to print area") do |x|
        options.top_page_margin = parse_dimension(x, 'top-page-margin')
      end
      parser.on("--bottom-page-margin=DIM",
                "Distance from bottom side of page (in portrait) to print area") do |x|
        options.bottom_page_margin = parse_dimension(x, 'bottom-page-margin')
      end
      parser.on("--h-page-margin=DIM",
                "Distance from left and right sides of page (in portrait) to print area") do |x|
        options.left_page_margin = options.right_page_margin = parse_dimension(x, 'h-page-margin')
      end
      parser.on("--v-page-margin=DIM",
                "Distance from top and bottom sides of page (in portrait) to print area") do |x|
        options.top_page_margin = options.bottom_page_margin = parse_dimension(x, 'v-page-margin')
      end
      parser.on("--page-margin=DIM",
                "Distance from all sides of page (in portrait) to print area") do |x|
        options.left_page_margin = options.right_page_margin =
          options.top_page_margin = options.bottom_page_margin = parse_dimension(x, 'margin')
      end
    end

    # Define a label name.  Perhaps the config files could contain a database
    # of common labels with their dimensions, so that --width and --height
    # need not be specified.
    def label_name_option
      parser.on("-lNAME", "--label=NAME",
                "Use options for label type NAME from label database") do |name|
        options.label = name.strip
        # Insert at this point the option args found in the Label.db
        lab_hash = LabelDb[name.to_sym]
        lab_hash.report("Config from labeldb entry '#{name}'") if options.verbose
        raise LabelNameError,
              "Unknown label name '#{name}'." if lab_hash.empty?

        lab_args = lab_hash.optionize
        parse(lab_args, verbose: options.verbose)
      end
    end

    def list_labels_option
      parser.on("--list-labels",
                "List known label types from label database and exit") do
        db_paths = Labrat::LabelDb.db_paths
        lab_names = Labrat::LabelDb.known_names
        if db_paths.empty?
          warn "Have you run labrat-install yet?"
        else
          warn "Label databases at:"
          db_paths.each do |p|
            warn "#{p}\n"
          end
          warn "\nKnown labels:\n"
          lab_names.groups_of(6).each do |_n, grp|
            warn "  #{grp.join(', ')}"
          end
        end
        exit(0)
      end
    end

    # Set the name, size, and style of font.
    def align_options
      parser.on("--h-align=[left|center|right|justify]", [:left, :center, :right, :justify],
                "Horizontal alignment of label text (default center)") do |al|
        options.h_align = al.to_sym
        warn "  ::h-align <- #{al}::" if options.verbose
      end
      parser.on("--v-align=[top|center|bottom]", [:top, :center, :bottom],
                "Vertical alignment of label text (default center)") do |al|
        options.v_align = al.to_sym
        warn "  ::v-align <- #{al}::" if options.verbose
      end
    end

    # Set the margins between the sides of the label and the bounding box to
    # hold the text of the label.  Left, right, top, and bottom are named
    # assuming a portrait orientation, that is the orientation the label has
    # as it comes out of the printer.
    def padding_options
      parser.on("--right-pad=DIM",
                "Distance from right side of label (in portrait) to print area") do |x|
        options.right_pad = parse_dimension(x, 'right-pad')
      end
      parser.on("--left-pad=DIM",
                "Distance from left side of label (in portrait) to print area") do |x|
        options.left_pad = parse_dimension(x, 'left-pad')
      end
      parser.on("--top-pad=DIM",
                "Distance from top side of label (in portrait) to print area") do |x|
        options.top_pad = parse_dimension(x, 'top-pad')
      end
      parser.on("--bottom-pad=DIM",
                "Distance from bottom side of label (in portrait) to print area") do |x|
        options.bottom_pad = parse_dimension(x, 'bottom-pad')
      end
      parser.on("--h-pad=DIM",
                "Distance from left and right sides of label (in portrait) to print area") do |x|
        options.left_pad = options.right_pad = parse_dimension(x, 'h-pad')
      end
      parser.on("--v-pad=DIM",
                "Distance from top and bottom sides of label (in portrait) to print area") do |x|
        options.top_pad = options.bottom_pad = parse_dimension(x, 'v-pad')
      end
      parser.on("--pad=DIM",
                "Distance from all sides of label (in portrait) to print area") do |x|
        options.left_pad = options.right_pad =
          options.top_pad = options.bottom_pad = parse_dimension(x, 'pad')
      end
    end

    # Set the name, size, and style of font.
    def font_options
      parser.on("--font-name=NAME",
                "Name of font to use (default Helvetica)") do |nm|
        options.font_name = nm
        warn "  ::font-name <- '#{nm}'::" if options.verbose
      end
      parser.on("--font-size=NUM",
                "Size of font to use in points (default 12)") do |pt|
        options.font_size = pt
        warn "  ::font-size <- #{pt}::" if options.verbose
      end
      parser.on("--font-style=[normal|bold|italic|bold-italic]",
                %w[normal bold italic bold-italic],
                "Style of font to use for text (default normal)") do |sty|
        # Prawn requires :bold_italic, not :"bold-italic"
        options.font_style = sty.tr('-', '_').to_sym
        warn "  ::font-style <- #{sty}::" if options.verbose
      end
    end

    # Even with accurate dimensions for labels, a combination of drivers, PDF
    # settings, and perhaps a particular printer may result in text not
    # sitting precisely where the user intends on the printed label.  These
    # options tweak the PDF settings to compensate for any such anomalies.
    def delta_options
      parser.on('-xDIM', "--delta-x=DIM",
                "Left-right adjustment as label text is oriented") do |x|
        options.delta_x = parse_dimension(x, 'delta-x')
      end
      parser.on('-yDIM', "--delta-y=DIM",
                "Up-down adjustment as label text is oriented") do |y|
        options.delta_y = parse_dimension(y, 'delta-y')
      end
    end

    # The name of the printer to send the job to.
    def printer_name_option
      parser.on("-pNAME", "--printer=NAME",
                "Name of the label printer to print on") do |name|
        options.printer = name
        warn "  ::printer <- '#{name}'::" if options.verbose
      end
    end

    def start_label_option
      parser.on("-SNUM", "--start-label=NUM", Integer,
                "Start printing at label number NUM (starting at 1, left-to-right, top-to-bottom)",
                "  within first page only.  Later pages always start at label 1.") do |n|
        options.start_label = n
        warn "  ::start-label <- #{n}::" if options.verbose
      end
    end

    # On a command-line, specifying where a line-break should occur is not
    # convenient when shell interpretation and quoting rules are taken into
    # account.  This allows the user to use some distinctive marker ('++' by
    # default) to designate where a line break should occur.
    def nl_sep_option
      parser.on("-nSEP", "--nlsep=SEPARATOR",
                "Specify text to be translated into a line-break (default '++')") do |nl|
        options.nlsep = nl
        warn "  ::nl-sep <- '#{nl}'::" if options.verbose
      end
    end

    # For batch printing of labels, the user might want to just feed a file of
    # labels to be printed.  This option allows a file name to be give.
    def in_file_option
      parser.on("-fFILENAME", "--in-file=FILENAME",
                "Read labels from given file instead of command-line") do |file|
        options.in_file = file.strip
        warn "  ::in-file <- '#{file}'::" if options.verbose
      end
    end

    # For batch printing of labels, the user might want to just feed a file of
    # labels to be printed.  This option allows a file name to be give.
    def out_file_option
      parser.on("-oFILENAME", "--out-file=FILENAME",
                "Put generated label in the given file") do |file|
        file = file.strip
        unless file =~ /\.pdf\z/i
          file = "#{file}.pdf"
        end
        options.out_file = file
        warn "  ::out-file <- '#{file}'::" if options.verbose
      end
    end

    def command_options
      # NB: the % is supposed to remind me of the rollers on a printer
      parser.on("-%PRINTCMD", "--print-command=PRINTCMD",
                "Command to use for printing with %p for printer name; %o for label file name") do |cmd|
        options.print_command = cmd.strip
        warn "  ::print-command <- '#{cmd}'::" if options.verbose
      end
      # NB: the : is supposed to remind me of two eyeballs viewing the PDF
      parser.on("-:VIEWCMD", "--view-command=VIEWCMD",
                "Command to use for viewing with %o for label file name") do |cmd|
        options.view_command = cmd.strip
        warn "  ::view-command <- '#{cmd}'::" if options.verbose
      end
    end

    # Whether the label ought to be printed in landscape orientation, that is,
    # the text turned 90 degrees clockwise from the orientation the label has
    # coming out of the printer.
    def landscape_option
      parser.on("-L", "--[no-]landscape",
                "Orient label in landscape (default false), i.e., with the left of",
                "the label text starting at the top as the label as printed") do |l|
        options.landscape = l
        warn "  ::landscape <- #{l}::" if options.verbose
      end
    end

    # The inverse of landscape, i.e., no rotation is done.
    def portrait_option
      parser.on("-P", "--[no-]portrait",
                "Orient label in portrait (default true), i.e., left-to-right",
                "top-to-bottom as the label as printed. Negated landscape") do |p|
        options.landscape = !p
        warn "  portrait option executed as ::landscape <- #{!p}::" if options.verbose
      end
    end

    # Whether to preview with the view command instead of print
    def view_option
      # Boolean switch.
      parser.on("-V", "--[no-]view", "View rather than print") do |v|
        options.view = v
        warn "  ::view <- #{v}::" if options.verbose
      end
    end

    # Whether to add label grid outline to output
    def grid_option
      # Boolean switch.
      parser.on("-g", "--[no-]grid", "Add grid lines to output") do |g|
        options.grid = g
        warn "  ::grid <- #{g}::" if options.verbose
      end
    end

    # Ignore any content from in-file, stdin, or the command-line and just
    # produce a template showing the boundaries of each label on a page of
    # labels.
    def template_option
      parser.on("-T", "--[no-]template",
                "Print a template of a page of labels and ignore any content.") do |t|
        options.template = t
        warn "  ::template <- #{t}::" if options.verbose
      end
    end

    # Whether we ought to be blabby about what we're up to.
    def verbose_option
      # Boolean switch.
      parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
        warn "  ::verbose <- #{v}::" if options.verbose
      end
    end
  end
end
