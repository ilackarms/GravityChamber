require 'chipmunk'

class StaticShapeWrapper  < GameObject
  attr_accessor :shape, :image, :vertices
  def initialize vertices, position, rotation, color
    super 'Polygon'
    @body = CP::Body.new_static
    @color = color
    @vertices = vertices
    @position = position
    @rotation = rotation
    @body.p = @position
    puts @vertices
    @shape = CP::Shape::Poly.new(@body, vertices, position)
    @image = DrawPoly.new(shift_vertices, CP::Vec2.new(0,0), @color)
    puts "1", @vertices
  end

  #don't call this on static objects i think??
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

  def draw
    @image.draw
    puts @body.p
  end
end