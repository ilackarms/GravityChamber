require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'dynamic_shape'

include DynamicShape
include Gosu

class GoalZone < Movable
  MASS = 1500
  ZERO_VEC = CP::Vec2.new(0, 0)
  SIZE = 15

  attr_accessor :is_grounded

  def initialize(window, space, x, y)
    @window = window
    @space = space
    @bounds = [CP::Vec2.new(-0.5,-0.65) * SIZE, CP::Vec2.new(-0.5,0.65) * SIZE, CP::Vec2.new(0.5,0.65) * SIZE, CP::Vec2.new(0.5,-0.65) * SIZE]
    create_dynamic_poly(x, y, MASS, :goal_zone)
    @color = 0xFF0066FF
  end

  def draw(offset_x = 0, offset_y = 0)
    @color += 0x00000001
    @color = @color % (0xFFFFFFFF - 0xFF0066FF) + 0xFF0066FF
    draw_polygon offset_x, offset_y
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

end