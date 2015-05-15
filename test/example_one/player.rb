require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'drawables'
require_relative 'dynamic_shape'
require_relative 'attraction_sphere'

include DynamicShape
include Gosu


class Player
  MASS = 100
  ACCELERATION = 1000/50
  JUMP_SPEED = 2000
  LEFT = CP::Vec2.new(-1, 0)
  RIGHT = CP::Vec2.new(1, 0)
  ZERO_VEC = CP::Vec2.new(0, 0)
  SIZE = 10

  attr_accessor :is_grounded

  def initialize(window, space, x, y)
    @window = window
    @space = space
    @bounds = [CP::Vec2.new(0,1) * SIZE, CP::Vec2.new(0.951057,0.309017) * SIZE, CP::Vec2.new(0.587785252,-0.80901699437) * SIZE, CP::Vec2.new(-0.587785252,-0.80901699437) * SIZE, CP::Vec2.new(-0.951057,0.309017) * SIZE]
    create_dynamic_poly(x, y, MASS, :block)
    @shape.collision_type = :player
    @shape.object = self
    @is_grounded = 4
    @cursor_sphere = Drawable::Circle.new @window
    @cursor_particles = Drawable::AttractorParticleSystem.new @window
    @spheres = []
  end

  def draw
    draw_polygon
    @cursor_sphere.draw @window.mouse_x, @window.mouse_y, 10, Gosu::Color::GRAY
    @cursor_particles.draw_special @window.mouse_x, @window.mouse_y, 10, Gosu::Color::GRAY
    @spheres.each.draw
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

  def handle_left_right_input
    if @window.button_down? Gosu::KbA or @window.button_down? Gosu::GpLeft then
      # @shape.body.apply_force(LEFT * ACCELERATION, ZERO_VEC)
      @shape.body.v = CP::Vec2.new(-1 * ACCELERATION, @shape.body.v.y)
    end
    if @window.button_down? Gosu::KbD or @window.button_down? Gosu::GpRight then
      # @shape.body.apply_force(RIGHT * ACCELERATION, ZERO_VEC)
      @shape.body.v = CP::Vec2.new(ACCELERATION, @shape.body.v.y)
    end
  end

  def is_grounded?
    @is_grounded > 0
    # #check immediately below player
    # #iterate through all walls in window
    # start = CP::Vec2.new(@shape.body.p.x, @shape.body.p.y + SIZE)
    # stop = CP::Vec2.new(@shape.body.p.x, @shape.body.p.y - SIZE)
    # sq_info = @shape.segment_query(start, stop) do
    #   |shape, t, n|
    # end
    # puts sq_info.shape
    # # sq_info != nil
  end

  def update
    @is_grounded -= 1
    handle_left_right_input
    if powers_enabled?
      if @window.button_down? Gosu::MsLeft
        @spheres <<
      end
    end
  end

  def create_sphere x, y

  end

  def powers_enabled
    true
  end

  def handle_jumping id
    if id == Button::KbW && is_grounded?
      # @shape.body.v = @shape.body.v + CP::Vec2.new(0, JUMP_SPEED)
      @shape.body.apply_impulse CP::Vec2.new(0, JUMP_SPEED * 4), ZERO_VEC
      @is_grounded = 0
    end
  end
end
