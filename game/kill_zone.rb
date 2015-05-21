require 'rubygems'
require "enumerator"
require_relative 'static_shape'
include StaticShape

class KillZone
  attr_accessor :shape
  def initialize(window, space, v1, v2)
    @window = window
    @space = space
    create_static_line(v1, v2, :kill_zone, 0xFFFF0000)
  end

  def draw offset_x = 0, offset_y = 0
    draw_wall offset_x, offset_y
  end

  def fric
    0.7
  end

  def elast
    0.1
  end

end