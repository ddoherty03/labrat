module Labrat
  class Options
    attr_accessor :label_width, :label_height, :label_name,
                  :delta_x, :delta_y, :printer_name,
                  :landscape, :nl_sep, :in_file,
                  :verbose, :msg

    def initialize
      self.label_width = 28.mm
      self.label_height = 88.mm
      self.label_name = nil
      self.delta_x = 0
      self.delta_y = 0
      self.printer_name = 'dymo'
      self.landscape = true
      self.nl_sep = '++'
      self.in_file = nil
      self.verbose = false
      self.msg = nil
    end

    # Return any string in msg, e.g., the usage help or error.
    def to_s
      msg
    end

    # Return a hash of the values in this Options object.
    def to_hash
      {
        label_width: label_width,
        label_height: label_height,
        label_name: label_name,
        delta_x: delta_x,
        delta_y: delta_y,
        printer_name: printer_name,
        landscape: landscape,
        nl_sep: nl_sep,
        in_file: in_file,
        verbose: verbose,
        msg: msg
      }
    end

    # Update the fields of this Option instance by merging in the values in
    # hsh into self.  Ignore any keys in hsh not corresponding to a setter for
    # an Options object.
    def merge_hash!(hsh)
      new_hash = to_hash.merger(hsh)
      new_hash.each_pair do |k, val|
        setter = "#{k}=".to_sym
        next unless respond_to?(setter)

        send(setter, val)
      end
      self
    end
  end
end
