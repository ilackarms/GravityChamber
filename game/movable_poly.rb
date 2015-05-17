require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'dynamic_shape'

include DynamicShape
include Gosu

class MovablePoly < Movable

  ZERO_VEC = CP::Vec2.new(0, 0)

  attr_accessor :is_grounded

  def initialize(window, space, x, y, width, height, mass)
    @window = window
    @space = space
    @bounds = [CP::Vec2.new(-1 * width,-1 * height), CP::Vec2.new(-1 * width, height), CP::Vec2.new(width, height), CP::Vec2.new(width,-1 * height)]
    create_dynamic_poly(x, y, mass, :movable_block)
    @shape.object = self
    @color = 0xFF999966
  end

  def draw
    draw_polygon
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

end