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
  MAX_HORIZONTAL_SPEED = ACCELERATION * 1.1

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
    if @active_power == :attractor_power
      @cursor_sphere.draw @window.mouse_x, @window.mouse_y, 10, Gosu::Color::GRAY
      @cursor_particles.draw_special @window.mouse_x, @window.mouse_y, 10, Gosu::Color::GRAY
      @spheres.each do |sphere| sphere.draw end
      if @spheres.size == @max_uses
        @power_use_text.draw(@spheres.size.to_s + " / " + @max_uses.to_s, 25, 25, 0, 1, 1, Gosu::Color::GREEN)
      else
        @power_use_text.draw(@spheres.size.to_s + " / ", 25, 25, 0, 1, 1, Gosu::Color::GRAY)
        @power_use_text.draw(@max_uses.to_s, 75, 25, 0, 1, 1, Gosu::Color::GREEN)
      end
    end
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

  def activate_powerup power, max_uses
    @active_power = power
    @max_uses = max_uses
    @power_use_text = Gosu::Font.new(@window, 'Courier', 24)
  end

  def is_grounded?
    @is_grounded > 0
  end

  def handle_input
    if @window.button_down? Gosu::KbA or @window.button_down? Gosu::GpLeft or @window.button_down? Gosu::KbLeft then
      # @shape.body.apply_force(LEFT * ACCELERATION, ZERO_VEC)
      # @shape.body.v = CP::Vec2.new(-1 * ACCELERATION, @shape.body.v.y)
      if @shape.body.v.x > MAX_HORIZONTAL_SPEED * -1
        @shape.body.apply_impulse CP::Vec2.new(JUMP_SPEED * -0.01, 0), ZERO_VEC
      end
    end
    if @window.button_down? Gosu::KbD or @window.button_down? Gosu::GpRight or @window.button_down? Gosu::KbRight then
      # @shape.body.apply_force(RIGHT * ACCELERATION, ZERO_VEC)
      # @shape.body.v = CP::Vec2.new(ACCELERATION, @shape.body.v.y)
      if @shape.body.v.x < MAX_HORIZONTAL_SPEED
        @shape.body.apply_impulse CP::Vec2.new(JUMP_SPEED * 0.01, 0), ZERO_VEC
      end
    end
    if @active_power == :attractor_power
      if @window.button_down? Gosu::MsLeft
        #if we click on a sphere we already have, make it bigger insetad of adding more
        @spheres.each do
        |sphere|
          if sphere.p.dist(CP::Vec2.new(@window.mouse_x, @window.mouse_y)) < sphere.radius * 1.1
            sphere.amplify 0.01
          end
        end
      end
    end
  end

  def handle_button_down id
    if id == Button::KbW or id == Button::KbUp
        if is_grounded?
          # @shape.body.v = @shape.body.v + CP::Vec2.new(0, JUMP_SPEED)
          @shape.body.apply_impulse CP::Vec2.new(0, JUMP_SPEED * 3), ZERO_VEC
          @is_grounded = 0
        end
    end
    if @active_power == :attractor_power
      if id == Gosu::MsLeft
        #if we click on a sphere we already have, make it bigger insetad of adding more
        clicked_on_sphere = false
        @spheres.each do
        |sphere|
          if sphere.p.dist(CP::Vec2.new(@window.mouse_x, @window.mouse_y)) < sphere.radius * 1.1
            clicked_on_sphere = true
          end
        end
        #if we didnt click on a sphere, make one
        unless clicked_on_sphere
          if @spheres.size < @max_uses
            @spheres << AttractionSphere.new(@window, @window.mouse_x, @window.mouse_y, 10, Gosu::Color::GREEN)
          end
        end
      end
      if id == Gosu::MsRight
        @spheres.each do
          |sphere|
          if sphere.p.dist(CP::Vec2.new(@window.mouse_x, @window.mouse_y)) < sphere.radius * 1.1
            @spheres.delete(sphere)
          end
        end
      end
    end
  end
end
