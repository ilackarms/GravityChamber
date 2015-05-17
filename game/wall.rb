require 'rubygems'
require "enumerator"
require_relative 'static_shape'
include StaticShape

class Wall
  attr_accessor :shape
  def initialize(window, space, v1, v2)
    @window = window
    @space = space
    create_static_line(v1, v2, :wall, 0xFFFFFFFF)
  end

  def draw
    draw_wall
  end

  def fric
    0.7
  end

  def elast
    0.1
  end

end