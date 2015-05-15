require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'dynamic_shape'

include DynamicShape
include Gosu

class PowerUp < Movable
  MASS = 15
  ZERO_VEC = CP::Vec2.new(0, 0)
  SIZE = 15

  attr_accessor :is_grounded

  def initialize(window, space, x, y, powerup_type)
    @window = window
    @space = space
    @bounds = [CP::Vec2.new(-0.65,-0.5) * SIZE, CP::Vec2.new(0,0.5) * SIZE, CP::Vec2.new(0.65,-0.5) * SIZE]
    create_dynamic_poly(x, y, MASS, powerup_type)
    @shape.object = self
  end

  def draw
    @color += 0x00000005
    if @color < 0xFF65FF33 or @color >0xFF66FF66
      @color = 0xFF66FF33
    end
    draw_polygon
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

end