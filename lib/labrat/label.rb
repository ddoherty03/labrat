# frozen_string_literal: true

require 'pry'

module Labrat
  class Label
    attr_reader :text, :ops

    def initialize(text, ops)
      @ops = ops
      @text = text.gsub(ops.nlsep, "\n")
    end

    def generate
      layout = ops.landscape ? :landscape : :portrait
      # The default margin is 0.5in, way too big for labels, so it is
      # important to set these here.  The margins' designation as "top,"
      # "left," "bottom," and "right" take into account the page layout.  That
      # is, the left margin is on the left in both portrait and landscape
      # orientations.  But I want the user to be able to set the margins
      # according to the label type, independent of the orientation.  I adopt
      # the convention that the margins are named assuming a portrait
      # orientation and swap them here so that when Prawn swaps them again,
      if layout == :portrait
        tm = ops.top_margin
        bm = ops.bottom_margin
        lm = ops.left_margin
        rm = ops.right_margin
      else
        lm = ops.top_margin
        rm = ops.bottom_margin
        tm = ops.left_margin
        bm = ops.right_margin
      end

      Prawn::Document.generate(ops.out_file, page_size: [ops.width, ops.height],
                               left_margin: lm, right_margin: rm,
                               top_margin: tm, bottom_margin: bm,
                               page_layout: layout) do |pdf|
        # We are setting up the box within which the text of the label will be
        # printed.  Its width should be reduced by the side margins and its
        # height by the top and bottom margins.  Since the use specifies label
        # "width" and "height" using the portrait layout, we need to swap
        # those if a landscape orientation is used.
        box_wd = (ops.landscape ? ops.height : ops.width) - lm - rm
        box_ht = (ops.landscape ? ops.width : ops.height) - tm - bm
        # The first parameter to bounding_box is the top-left corner of the
        # bounding box relative to the margin box set up for the page. The
        # user can push this around with delta_x and delta_y (within the
        # limits of the printer) if the peculiarities of the printer require
        # it.
        box_x = 0.mm + ops.delta_x
        box_y = box_ht + ops.delta_y
        if ops.verbose
          warn "orientation: #{layout}"
          warn "page_size = [#{ops.width}pt,#{ops.height}pt]"
          warn "[lm, rm] = [#{lm}pt,#{rm}pt]"
          warn "[tm, bm] = [#{tm}pt,#{bm}pt]"
          warn "[delta_x, delta_y] = [#{ops.delta_x}pt,#{ops.delta_y}pt]"
          warn "[box_x, box_y] = [#{box_x}pt,#{box_y}pt]"
          warn "[box_wd, box_ht] = [#{box_wd}pt,#{box_ht}pt]"
        end
        pdf.bounding_box([box_x, box_y], width: box_wd, height: box_ht) do
          pdf.stroke_bounds
          pdf.font ops.font_name, style: ops.font_style.to_sym, size: ops.font_size.to_f
          pdf.text text, align: ops.h_align, valign: ops.v_align
        end
      end
      self
    end

    def print
      cmd = ops.print_command.gsub('%p', ops.printer).gsub('%o', ops.out_file)
      system("#{cmd} &")
    end

    def view
      cmd = ops.view_command.gsub('%o', ops.out_file)
      system("#{cmd} &")
    end
  end
end
