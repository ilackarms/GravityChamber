require 'rubygems'
require 'gosu'
require 'chipmunk'
require_relative 'player'
require_relative 'block'
require_relative 'wall'
require_relative 'game'
include CP

module Raycasting
  attr_accessor :shape
  class Raycast
    def initialize p1, p2
      @shape = Shape::Segment.new(p1.x, p1.y, p2.x, p2.y)
      @shape.sensor = true
      @shape.collision_type = :raycast
    end
  end
end
