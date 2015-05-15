require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'drawables'
require_relative 'dynamic_shape'
require_relative 'attraction_sphere'

include DynamicShape
include Gosu


class Player < Movable
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
    @spheres.each do |sphere| sphere.draw end
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

  def update
    @is_grounded -= 1
    @spheres.each do
      |sphere|
      sphere.attract
    end
    handle_input
  end

  def powers_enabled?
    true
  end

  def is_grounded?
    @is_grounded > 0
  end

  def handle_input
    if @window.button_down? Gosu::KbA or @window.button_down? Gosu::GpLeft then
      # @shape.body.apply_force(LEFT * ACCELERATION, ZERO_VEC)
      @shape.body.v = CP::Vec2.new(-1 * ACCELERATION, @shape.body.v.y)
    end
    if @window.button_down? Gosu::KbD or @window.button_down? Gosu::GpRight then
      # @shape.body.apply_force(RIGHT * ACCELERATION, ZERO_VEC)
      @shape.body.v = CP::Vec2.new(ACCELERATION, @shape.body.v.y)
    end
  end

  def handle_button_down id
    if id == Button::KbW && is_grounded?
      # @shape.body.v = @shape.body.v + CP::Vec2.new(0, JUMP_SPEED)
      @shape.body.apply_impulse CP::Vec2.new(0, JUMP_SPEED * 4), ZERO_VEC
      @is_grounded = 0
    end
    if powers_enabled?
      if id == Gosu::MsLeft
        @spheres << AttractionSphere.new(@window, @window.mouse_x, @window.mouse_y, 10, Gosu::Color::GRAY)
      end
      if id == Gosu::MsRight
        @spheres.each do
          |sphere|
          if sphere.p.dist(CP::Vec2.new(@window.mouse_x, @window.mouse_y)) < 20
            @spheres.delete(sphere)
          end
        end
      end
    end
  end
end
