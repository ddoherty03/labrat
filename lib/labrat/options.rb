module Labrat
  class Options
    attr_accessor :delta_x, :delta_y, :printer_name, :nl_marker,
                  :in_file, :label_width, :label_height,
                  :landscape, :verbose, :msg

    def initialize
      self.msg = nil
      self.label_width = 28.mm
      self.label_height = 88.mm
      self.delta_x = 0
      self.delta_y = 0
      self.printer_name = 'dymo'
      self.nl_marker = '++'
      self.in_file = nil
      self.landscape = true
    end
  end
end
