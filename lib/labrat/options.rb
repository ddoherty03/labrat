module Labrat
  class Options
    attr_accessor :width, :height, :label,
                  :delta_x, :delta_y, :printer,
                  :landscape, :nlsep, :file,
                  :verbose, :msg

    def initialize
      self.width = 28.mm
      self.height = 88.mm
      self.label = nil
      self.delta_x = 0
      self.delta_y = 0
      self.printer = 'dymo'
      self.landscape = true
      self.nlsep = '++'
      self.file = nil
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
        width: width,
        height: height,
        label: label,
        delta_x: delta_x,
        delta_y: delta_y,
        printer: printer,
        landscape: landscape,
        nlsep: nlsep,
        file: file,
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
