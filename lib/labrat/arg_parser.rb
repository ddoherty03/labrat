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

    # Return an Options object instance describing the options represented by
    # an Array of strings given by args.  If a Hash or Options object prior is
    # given, the parsed options are merged into it.  Throw an exception for
    # errors encountered parsing the args.
    def parse(args, prior = {})
      options.merge!(prior)
      options.msg = nil
      parser.parse!(args)
      options
    rescue OptionParser::ParseError => e
      options.msg = "Error: #{e}\n\n#{parser}"
      options
    end

    # Convert the given Hash into a Array of Strings that represent an
    # equivalent set of command-line args and pass them into the #parse
    # method.
    def from_hash(hsh = {})
      args = []
      hsh.each_pair do |k, v|
        args <<
          if [TrueClass, FalseClass].include?(v.class)
            v ? "--#{k}" : "--no-#{k}"
          else
            "--#{k}=#{v}"
          end
      end
      parse(args)
    end

    private

    # Define the OptionParser rules for acceptable options in Labrat.
    def define_options
      parser.banner = "Usage: labrat [options] <label-text>"
      parser.separator ""
      parser.separator "Print or view (with -V) a label with the given <label-text>."
      parser.separator "All non-option arguments are used for the text with a special"
      parser.separator "marker ('++' by default) indicating a line-break."
      parser.separator ""
      parser.separator "Specific options:"
      parser.separator "  Note: for DIM, valid units are: " +
                       "pt, mm, cm, dm, m, in, ft, yd"
      parser.separator "    With no units, pt (points) assumed"

      page_dimension_options
      page_margin_options
      label_name_option
      list_labels_option
      align_options
      delta_options
      padding_options
      font_options
      printer_name_option
      nl_sep_option
      in_file_option
      out_file_option
      print_and_view_command_options
      view_option
      template_option
      landscape_option
      portrait_option
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
          msg = "unknown #{where} unit: '#{match[:unit]}'\n"\
          "  valid units are: pt, mm, cm, dm, m, in, ft, yd"
          raise Labrat::DimensionError, msg
        end

        meas.send(u_meth)
      end
    end

    # Define options for specifying the dimensions of a page of labels to be
    # printed on.
    def page_dimension_options
      # Specifies an optional option argument
      parser.on("-wDIM", "--page-width=DIM",
                "Page width:",
                "the horizontal dimension of a page of labels as it comes out of the printer") do |wd|
        options.page_width = parse_dimension(wd, 'page-width')
      end
      parser.on("-hDIM", "--page-height=DIM",
                "Page height:",
                "the vertical dimension of a page of labels as it comes out of the printer") do |ht|
        options.page_height = parse_dimension(ht, 'page-height')
      end
      parser.on("-RNUM_ROWS", "--rows=NUM_ROWS", Integer,
                "Number of rows of labels on a page") do |n|
        options.rows = n
      end
      parser.on("-CNUM_COLUMNS", "--columns=NUM_COLUMNS", Integer,
                "Number of columns of labels on a page") do |n|
        options.columns = n
      end
      parser.on("--row-gap=DIM",
                "Row gap:",
                "the vertical space between rows of labels on a page of labels") do |gap|
        options.row_gap = parse_dimension(gap, 'row-gap')
      end
      parser.on("--column-gap=DIM",
                "Column gap:",
                "the horizontal space between columns of labels on a page of labels") do |gap|
        options.column_gap = parse_dimension(gap, 'row-gap')
      end
      parser.on("-SNUM", "--start-label=NUM", Integer,
                "Label number (starting at 1, left-to-right, top-to-bottom)",
                "  within first page to on which to start printing") do |n|
        options.start_label = n
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
                "Name of the label to print on") do |name|
        options.label = name.strip
        # Insert at this point the option args found in the Label.db
        lab_hash = LabelDb[name]
        raise LabelNameError,
              "Unknown label name '#{name}'." if lab_hash.empty?

        lab_args = from_hash(lab_hash)
        parser.parse(lab_args, into: options)
      end
    end

    def list_labels_option
      parser.on("--list-labels",
                "List known labels and exit") do
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
      parser.on("--h-align=[left|center|right]", [:left, :center, :right],
                "Horizontal alignment of label text (default center)") do |al|
        options.h_align = al.to_sym
      end
      parser.on("--v-align=[top|center|bottom]", [:top, :center, :bottom],
                "Vertical alignment of label text (default center)") do |al|
        options.h_align = al.to_sym
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
      end
      parser.on("--font-size=POINTS",
                "Size of font to use in points (default 12)") do |pt|
        options.font_size = pt
      end
      parser.on("--font-style=[normal|bold|italic|bold-italic]",
                %w[normal bold italic bold-italic],
                "Style of font to use for text (default normal)") do |sty|
        options.font_style = sty
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
      end
    end

    # On a command-line, specifying where a line-break should occur is not
    # convenient when shell interpretation and quoting rules are taken into
    # account.  This allows the user to use some distinctive marker ('++' by
    # default) to designate where a line break should occur.
    def nl_sep_option
      parser.on("-nSEP", "--nlsep=SEPARATOR",
                "Specify text to be interpreted as a line-break (default '++')") do |nl|
        options.nlsep = nl
      end
    end

    # For batch printing of labels, the user might want to just feed a file of
    # labels to be printed.  This option allows a file name to be give.
    def in_file_option
      parser.on("-fFILENAME", "--file=FILENAME",
                "Read labels from given file instead of command-line") do |file|
        options.file = file.strip
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
      end
    end

    def print_and_view_command_options
      # NB: the % is supposed to remind me of the rollers on a printer
      parser.on("-%PRINTCMD", "--print-command=PRINTCMD",
                "Command to use for printing with %p for printer name; %o for label file name") do |cmd|
        options.print_command = cmd.strip
      end
      # NB: the : is supposed to remind me of two eyeballs viewing the PDF
      parser.on("-:VIEWCMD", "--view-command=VIEWCMD",
                "Command to use for viewing with %o for label file name") do |cmd|
        options.view_command = cmd.strip
      end
    end

    # Whether the label ought to be printed in landscape orientation, that is,
    # turned 90 degrees clockwise from the orientation the label has coming
    # out of the printer.
    def landscape_option
      parser.on("-L", "--[no-]landscape",
                "Print label in landscape (default true), i.e., with the left of",
                "the label text starting at the top as the label in printed") do |l|
        options.landscape = l
      end
    end

    # The inverse of landscape, i.e., no rotation is done.
    def portrait_option
      parser.on("-P", "--[no-]portrait",
                "Print label in portrait (default false), i.e., left-to-right",
                "top-to-bottom as the label in printed. Negated landscape") do |p|
        options.landscape = !p
      end
    end

    # Whether to preview with the view command instead of print
    def view_option
      # Boolean switch.
      parser.on("-V", "--[no-]view", "View rather than print") do |v|
        options.view = v
      end
    end

    # Ignore any content from in-file, stdin, or the command-line and just
    # produce a template showing the boundaries of each label on a page of
    # labels.
    def template_option
      parser.on("-T", "--[no-]template",
                "Print a template of a page of labels and ignore any content.") do |t|
        options.template = t
      end
    end

    # Whether we ought to be blabby about what we're up to.
    def verbose_option
      # Boolean switch.
      parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end
    end
  end
end
