# frozen_string_literal: true

module Labrat
  def self.read_label_texts(fname, nl_sep)
    file =
      if fname
        ofname = fname
        fname = File.expand_path(fname)
        unless File.readable?(fname)
          raise "Cannot open label file '#{ofname}' for reading"
        end

        File.open(fname)
      else
        $stdin
      end

    texts = []
    label = nil
    file.each do |line|
      next if /\A\s*#/.match?(line)

      if /\A\s*\z/.match?(line)
        # At blank line record any accumulated label into texts, but remove
        # the nl_sep from the end.
        if label
          texts << label.sub(/#{Regexp.quote(nl_sep)}\z/, '')
          label = nil
        end
      else
        # Append a non-blank line to the current label, creating it if
        # necessary.
        label ||= +''
        label << line.chomp + nl_sep
      end
    end
    # Last label in the file.
    texts << label.sub(/#{Regexp.quote(nl_sep)}\z/, '') if label
    texts
  end
end
