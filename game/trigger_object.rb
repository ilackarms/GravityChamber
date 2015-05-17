require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'static_shape'

include StaticShape
include Gosu

class TriggerObject #not movable

  ZERO_VEC = CP::Vec2.new(0, 0)

  attr_accessor :is_grounded, :shape

  def initialize(window, space, x, y, width, height, lambda_array, attached_obj=nil, visible=false, color=Color::AQUA)
    @window = window
    @space = space
    width/=2
    height/=2
    @x = x
    @y = y
    @bounds = [CP::Vec2.new(-1 * width,-1 * height), CP::Vec2.new(-1 * width, height), CP::Vec2.new(width, height), CP::Vec2.new(width,-1 * height)]
    create_static_box(x, y, :trigger, color)
    lambda_array << self
    @shape.object = lambda_array
    @shape.sensor = true
    @visible = visible
    set_to_follow attached_obj
  end

  def draw
    #follow object behavior! TODO: should not be in draw method
    #@follow_obj must be a Movable
    if @follow_obj != nil
      @shape.body.p = @follow_obj.shape.body.p
    else
      @shape.body.p.x = @x
      @shape.body.p.y = @y
    end
    if @visible
      draw_polygon
    end
  end

  def set_to_follow movable
    @follow_obj = movable
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

end