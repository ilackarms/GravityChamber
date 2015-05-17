require 'chipmunk'
require_relative 'drawables'

class AttractionSphere
  attr_accessor :p, :world_coordinates, :radius
  def initialize window, x, y, radius, color
    @attraction_strength = 100
    @window = window
    @p = CP::Vec2.new(x,y)
    @world_coordinates = CP::Vec2.new(x, @window.height - y)
    @color = color
    @radius = radius
    @circle = Drawable::Circle.new window
    @particles = Drawable::AttractorParticleSystem.new window
  end

  def amplify amount
    @attraction_strength += 33 * amount
    @radius += amount
  end

  def attract
    @window.attract_all_towards_point(@world_coordinates, @attraction_strength)
  end

  def draw
    @circle.draw @p.x, @p.y, @radius, @color
    @particles.draw_special @p.x, @p.y, @radius, @color
  end
end