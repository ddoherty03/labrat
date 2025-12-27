# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'fat_core/enumerable'
require 'fat_config'
require 'prawn'
require 'prawn/measurement_extensions'
require 'optparse'
require 'yaml'
require 'pp'

# Gem Overview (extracted from README.org by gem_docs)
#
# * Introduction
# This gem provides a command-line application, ~labrat~, for the easy printing
# of labels after suitable configuration.  It also provides an Emacs library for
# easily invoking ~labrat~ from within Emacs to make a label from the paragraph
# at point.
#
# It can handle everything from label printers such as the Dymo LabelWriter
# geared toward single label printing to full-size printers for printing a
# series of labels on label sheets from Avery or other suppliers of label
# sheets.  It includes a library of pre-configured settings for around 250 label
# products, and provides a convenient way to define new ones or variations on
# the pre-configured ones.
#
# It also provides aids to configuring new labels such as printing page grids based
# on label definitions to refine new label definitions.
#
# Easy-to-print labels can make the process of creating file folders trivial,
# but there are many other uses for them, such as badges and marking cables, electrical
# panels, ports, and outlets.
#
# Buy your copy today while supplies last!
module Labrat
  require_relative "labrat/version"
  require_relative "labrat/errors"
  require_relative "labrat/hash"
  require_relative "labrat/options"
  require_relative "labrat/arg_parser"
  require_relative "labrat/label"
  require_relative "labrat/config"
  require_relative "labrat/label_db"
  require_relative "labrat/read_files"
end
