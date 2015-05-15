require_relative '../drawables'

class AttractionSphere
  def initialize window, x, y, radius, color
    @window = window
    @x = x
    @y = y
    @color = color
    @radius = radius
    @circle = Drawable::Circle.new window
    @particles = Drawable::AttractorParticleSystem.new window
  end

  def draw
    @circle.draw @x, @y, @radius, @color
    @particles.draw_special @x, @y, @radius, @color
  end
end