require_relative '../labrat'

module Labrat
  class ArgParser
    attr_reader :parser, :args, :options

    def initialize
      @options = Labrat::Options.new
      @parser = OptionParser.new
      define_options
    end

    # Return an Options object instance describing the options.
    def parse(args)
      options.msg = nil
      parser.parse!(args)
      options
    rescue OptionParser::InvalidOption => e
      options.msg = "Error: #{e}\n\n#{parser}"
      options
    end

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
      delta_options
      printer_name_option
      nl_sep_option
      in_file_option
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

    def parse_dimension(str, where = '')
      unless (match = str.match(/\A\s*(?<measure>[0-9.]+)\s*(?<unit>[A-Za-z]*)\s*\z/))
        raise Labrat::DimensionError, "illegal #{where} dimension: '#{str}'"
      end

      if match[:unit].empty?
        match[:measure].to_f
      else
        meas = match[:measure].to_f
        u_meth = match[:unit].to_sym
        unless meas.respond_to?(u_meth)
          msg = "unknown #{where} unit: '#{match[:unit]}'\n"
          "  valid units are: pt, mm, cm, dm, m, in, ft, yd"
          raise Labrat::DimensionError, msg
        end

        meas.send(u_meth)
      end
    end

    def label_dimension_options
      # Specifies an optional option argument
      parser.on("-w", "--width [DIMENSION]",
                "Label width:",
                "the horizontal dimension of the label as it comes out of the printer") do |wd|
        options.label_width = parse_dimension(wd, 'width')
      end
      parser.on("-h", "--height [DIMENSION]",
                "Label height:",
                "the vertical dimension of label as it comes out of the printer") do |ht|
        options.label_height = parse_dimension(ht, 'height')
      end
    end

    def delta_options
      parser.on('-x', "--delta_x [DIMENSION]",
                "Left-right adjustment as label text is oriented") do |x|
        options.delta_x = parse_dimension(x, 'delta_x')
      end
      parser.on('-y', "--delta_y [DIMENSION]",
                "Up-down adjustment as label text is oriented") do |y|
        options.delta_y = parse_dimension(y, 'delta_y')
      end
    end

    def printer_name_option
      parser.on("-p", "--printer [NAME]",
                "Name of the label printer to print on") do |name|
        options.printer_name = name
      end
    end

    def nl_sep_option
      parser.on("-n", "--nlsep [SEPARATOR]",
                "Specify text to be interpreted as a line-break (default '++')") do |nl|
        options.nl_sep = nl
      end
    end

    def in_file_option
      parser.on("-f", "--file [FILENAME]",
                "Read labels from given file instead of command-line") do |file|
        options.in_file = file
      end
    end

    def landscape_option
      parser.on("-L", "--landscape",
                "Print label in landscape (default true), i.e., with the left of",
                "the label text starting at the top as the label in printed") do
        options.landscape = true
      end
    end

    def portrait_option
      parser.on("-P", "--portrait",
                "Print label in portrait (default false), i.e., left-to-right",
                "top-to-bottom as the label in printed. Negated landscape") do
        options.landscape = false
      end
    end

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
