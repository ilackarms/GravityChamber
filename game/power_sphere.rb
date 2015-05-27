require_relative 'lib/chipmunk.so'
require 'gosu'
require_relative 'drawables'

class PowerSphere
  attr_accessor :p, :world_coordinates, :radius
  def initialize window, x, y, radius, collision_type
    @attraction_strength = 100
    @window = window
    @p = CP::Vec2.new(x,y)
    @world_coordinates = CP::Vec2.new(x, @window.height - y)
    if collision_type == :attractor_power
      @color = Gosu::Color::GREEN
    end
    if collision_type == :repulsion_power
      @color = 0xFFC680FF
    end
    @radius = radius
    @circle = Drawable::Circle.new window
    @particles = Drawable::ParticleSystem.new window
    @sphere_type = collision_type
    @strength_font = Gosu::Font.new(@window, "Courier", 13)
  end

  def amplify amount
    @attraction_strength += 33 * amount
    @radius += amount
  end

  def attract_repel
    reverse = 1
    if @sphere_type == :repulsion_power
      reverse = -1
    end
    @window.attract_all_towards_point(@world_coordinates, @attraction_strength * reverse)
  end

  def draw offset_x = 0, offset_y = 0
    @circle.draw @p.x, @p.y, @radius, @color, offset_x, offset_y
    @particles.draw_special @p.x, @p.y, @radius, @color, @sphere_type, offset_x, offset_y
    @strength_font.draw("%.1f" % (@attraction_strength/100.0), @p.x - 10 + offset_x, @p.y - 10 + offset_y, 0, 1, 1, @color)
  end
end