# frozen_string_literal: true

module Labrat
  # The Options class is a glorified Hash, a container for the options
  # settings gathered from the defaults, the config files, the command line,
  # and perhaps environment.  An Options instance can be handed off to the
  # label-printing objects to inform its formatting, printing, etc.
  class Options
    attr_accessor :width, :height, :label,
                  :delta_x, :delta_y, :printer,
                  :landscape, :nlsep, :file, :out_file,
                  :print_command, :view_command,
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
      self.out_file = './label.pdf'
      self.print_command = 'lpr -P %p %o'
      self.view_command = 'zathura %o'
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
        out_file: out_file,
        print_command: print_command,
        view_command: view_command,
        verbose: verbose,
        msg: msg,
      }
    end

    # Update the fields of this Option instance by merging in the values in
    # hsh into self.  Ignore any keys in hsh not corresponding to a setter for
    # an Options object.
    def merge_hash!(hsh)
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
