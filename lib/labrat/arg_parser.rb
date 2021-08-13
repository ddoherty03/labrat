# frozen_string_literal: true

module Labrat
  # An ArgParser object implements parsing of command-line arguments and
  # gathering them into an Options object.  By using the from_hash method, you
  # can get an ArgParser object to also treat a Hash as if it were a set of
  # command-line arguments so that config files, converted to a Hash can also
  # be used with an ArgParser.
  class ArgParser
    attr_reader :parser, :args, :options

    def initialize
      @options = Labrat::Options.new
      @parser = OptionParser.new
      define_options
    end

    # Return an Options object instance describing the options represented by
    # an Array of strings given by args.  Throw an exception for errors
    # encountered parsing the args.
    def parse(args)
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
        args << "--#{k}=#{v}"
      end
      parse(args)
    end

    private

    # Define the OptionParser rules for acceptable options in Labrat.
    def define_options
      parser.banner = "Usage: labrat [options]"
      parser.separator ""
      parser.separator "Specific options:"
      parser.separator "  Note: for DIMENSION, valid units are: " +
                       "pt, mm, cm, dm, m, in, ft, yd"
      parser.separator "    With no units, pt (points) assumed"
      parser.separator ""

      # add additional options
      label_dimension_options
      label_name_option
      delta_options
      printer_name_option
      nl_sep_option
      in_file_option
      out_file_option
      print_and_view_options
      landscape_option
      portrait_option
      verbose_option

      parser.separator ""
      parser.separator "Common options:"
      # Normally, options.msg is nil.  If it is set to a string, we want
      # the main program to print the string and exit.
      options.msg = nil
      parser.on_tail("-h", "--help", "Show this message") do
        # NB: parser.to_s returns the usage message.
        options.msg = parser.to_s
      end
      # Another typical switch to print the version.
      parser.on_tail("--version", "Show version") do
        options.msg = VERSION
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

    # Define options for specifying the dimensions of the label to be printed
    # on.
    def label_dimension_options
      # Specifies an optional option argument
      parser.on("-wDIMENSION", "--width DIMENSION",
                "Label width:",
                "the horizontal dimension of the label as it comes out of the printer") do |wd|
        options.width = parse_dimension(wd, 'width')
      end
      parser.on("-hDIMENSION", "--height DIMENSION",
                "Label height:",
                "the vertical dimension of label as it comes out of the printer") do |ht|
        options.height = parse_dimension(ht, 'height')
      end
    end

    # Define a label name.  Perhaps the config files could contain a database
    # of common labels with their dimensions, so that --width and --height
    # need not be specified.
    def label_name_option
      parser.on("-lNAME", "--label=NAME",
                "Name of the label to print on") do |name|
        options.label = name.strip
      end
    end

    # Even with accurate dimensions for labels, a combination of drivers, PDF
    # settings, and perhaps a particular printer may result in text not
    # sitting precisely where the user intends on the printed label.  These
    # options tweak the PDF settings to compensate for any such anomalies.
    def delta_options
      parser.on('-xDIMENSION', "--delta_x=DIMENSION",
                "Left-right adjustment as label text is oriented") do |x|
        options.delta_x = parse_dimension(x, 'delta_x')
      end
      parser.on('-yDIMENSION', "--delta_y=DIMENSION",
                "Up-down adjustment as label text is oriented") do |y|
        options.delta_y = parse_dimension(y, 'delta_y')
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

    def print_and_view_options
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

    # Whether we ought to be blabby about what we're up to.
    def verbose_option
      # Boolean switch.
      parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end
    end
  end
end

# options = Labrat::Optparse.new.parse(ARGV)
# pp ARGV
# pp options # example.options
