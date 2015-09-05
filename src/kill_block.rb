require 'rubygems'
require "enumerator"
require 'gosu'
require_relative 'dynamic_shape'
include DynamicShape

class KillBlock < Movable
  def initialize(window, space, x, y, width, height, mass)
    @window = window
    @space = space
    @bounds = [CP::Vec2.new(-1 * width,-1 * height), CP::Vec2.new(-1 * width, height), CP::Vec2.new(width, height), CP::Vec2.new(width,-1 * height)]
    create_physical_poly(x, y, mass, :kill_zone)
    @color = Gosu::Color::RED
    @is_alive = true
    @shape.object = self
  end

  def draw(offset_x = 0, offset_y = 0)
    if @is_alive
      draw_polygon(offset_x, offset_y)
    else
      @death_animation.draw_special @shape.body.p.x, @window.height - @shape.body.p.y, 10, @color, :repulsion_power, offset_x, offset_y, 9
    end
  end

  def fric
    0.7
  end

  def elast
    0.5
  end

  def destroy color = nil
    @is_alive = false
    if color != nil
      @color = color
    end
    @shape.collision_type = :dead
    @death_animation = Drawable::ParticleSystem.new @window
  end

end