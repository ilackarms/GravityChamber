require 'chipmunk'


class ShapeWrapper < GameObject
  attr_accessor :shape, :image, :vertices
  def initialize vertices, mass, position, rotation, color
    super 'Polygon'
    @body = CP::Body.new(mass, CP.moment_for_poly(mass, vertices, CP::Vec2.new(0,0)))
    @color = color

    #shift points by center
    x = 0
    y = 0
    vertices.each do
      |v|
      x += v.x
      y += v.y
    end
    center = CP::Vec2.new(x/vertices.size, y/vertices.size)
    vertices.each_with_index do
      |v, index|
      vertices[index] -= center
    end

    @vertices = vertices
    @position = position
    @rotation = rotation
    @body.p = @position
    puts @vertices
    @shape = CP::Shape::Poly.new(@body, vertices, position)
    @shape.group = 0
    @image = DrawPoly.new(shift_vertices, CP::Vec2.new(0,0), @color)
    puts "1", @vertices
  end

  def update
    @position = @body.p
    @rotation = @body.a
    @image = DrawPoly.new(shift_vertices, CP::Vec2.new(0,0), @color)
  end

  def shift_vertices
    #vertices are expected relative to center, and lacking rotation
    vertices = []
    @vertices.each_with_index do
    |v, index|
      #first, rotate vertices around origin
      shift_v = CP::Vec2.new(v.x * Math::cos(@rotation) - v.y * Math::sin(@rotation), v.x * Math::sin(@rotation) + v.y * Math::cos(@rotation))
      #then translate
      shift_v += @position
      vertices[index] = shift_v
    end
    vertices
  end

  def add_force f
    @body.apply_force(f, CP::Vec2.new(0,0))
  end

  def draw
    @image.draw
    puts @body.p
  end
end