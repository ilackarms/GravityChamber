require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'dynamic_shape'
include DynamicShape

class Block

  def initialize(window, space, x, y, width, height, mass)
      @window = window
      @space = space
      @bounds = [CP::Vec2.new(-1 * width,-1 * height), CP::Vec2.new(-1 * width, height), CP::Vec2.new(width, height), CP::Vec2.new(width,-1 * height)]
      create_pyhsical_poly(x, y, mass, :block)
      @color = Gosu::Color::WHITE
    end

  def draw(offset_x = 0, offset_y = 0)
      draw_polygon(offset_x, offset_y)
    end

  def fric
      0.7
    end

  def elast
      0.5
    end
end
