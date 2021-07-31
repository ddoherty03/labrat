module Labrat
  class Options
    attr_accessor :label_width, :label_height, :label_name,
                  :delta_x, :delta_y, :printer_name,
                  :landscape, :nl_sep, :in_file,
                  :verbose, :msg

    def initialize
      self.msg = nil
      self.label_width = 28.mm
      self.label_height = 88.mm
      self.label_name = nil
      self.delta_x = 0
      self.delta_y = 0
      self.printer_name = 'dymo'
      self.nl_sep = '++'
      self.in_file = nil
      self.landscape = true
    end
  end
end
