require 'rubygems'
require "enumerator"
require_relative 'physical_barrier'
include PhysicalBarrier

class Wall
  attr_accessor :shape
  def initialize(window, space, v1, v2)
    @window = window
    @space = space
    create_wall(v1, v2, :wall)
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