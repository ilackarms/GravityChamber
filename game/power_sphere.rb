require 'chipmunk'
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
    @particles = Drawable::AttractorParticleSystem.new window
    @sphere_type = collision_type
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

  def draw
    @circle.draw @p.x, @p.y, @radius, @color
    @particles.draw_special @p.x, @p.y, @radius, @color, @sphere_type
  end
end