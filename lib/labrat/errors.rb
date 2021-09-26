# frozen_string_literal: true

module Labrat
  class OptionError < StandardError; end
  class DimensionError < StandardError; end
  class LabelNameError < StandardError; end
  class EmptyLabelError < StandardError; end
  class RecursionError < StandardError; end
end
