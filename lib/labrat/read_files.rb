module Labrat
  def self.read_label_texts(fname, nlsep)
    ofname = fname
    fname = File.expand_path(fname)
    unless File.readable?(fname)
      raise "Cannot open label file '#{ofname}' for reading"
    end

    texts = []
    File.open(fname) do |f|
      label = nil
      f.each do |line|
        next if line =~ /\A#/

        if line =~ /\A\s*\z/
          # At blank line record any accumulated label into texts, but remove
          # the nlsep from the end.
          if label
            texts << label.sub(/#{Regexp.quote(nlsep)}\z/, '')
            label = nil
          end
        else
          # Append a non-blank line to the current label, creating it if
          # necessary.
          label ||= ''
          label << line.chomp + nlsep
        end
      end
      # Last label in the file.
      texts << label.sub(/#{Regexp.quote(nlsep)}\z/, '') if label
    end
    texts
  end
end
