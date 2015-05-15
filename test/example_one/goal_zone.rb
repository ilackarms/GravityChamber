require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'dynamic_shape'

include DynamicShape
include Gosu

class GoalZone
  MASS = 100
  ZERO_VEC = CP::Vec2.new(0, 0)
  SIZE = 10

  attr_accessor :is_grounded

  def initialize(window, space, x, y)
    @window = window
    @space = space
    @bounds = [CP::Vec2.new(-0.5,-0.5) * SIZE, CP::Vec2.new(-0.5,0.5) * SIZE, CP::Vec2.new(0.5,0.5) * SIZE, CP::Vec2.new(0.5,-0.5) * SIZE]
    create_dynamic_poly(x, y, MASS, :goal_zone)
  end

  def draw
    @color += 0x0000000E
    @color %= 0xFAFFFFFF + 0xFAFFFFFF
    draw_polygon
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

end