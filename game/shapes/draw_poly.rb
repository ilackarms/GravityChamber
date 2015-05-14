require_relative 'composite_draw_shape'
require_relative 'draw_line'
require 'chipmunk'
class DrawPoly < CompositeDrawShape
  attr_accessor  :position, :color

  def initialize vertex_list, position, color
    @vertex_list = vertex_list
    @position = position
    @color = color
    @components = []
    #draw a line between every pair of vertices in list
    uncounted_vertices = vertex_list
    while uncounted_vertices.size > 1
      v = uncounted_vertices.pop
      uncounted_vertices.each {
        |u| @components << DrawLine.new(u, v, @color)
      }
    end
  end

  def update vertex_list, position, color
    @vertex_list = vertex_list
    @position = position
    @color = color
    @components = []
    #draw a line between every pair of vertices in list
    uncounted_vertices = [] << vertex_list
    while uncounted_vertices.size > 1
      v = uncounted_vertices.pop
      uncounted_vertices.each {
          |u| @components << DrawLine.new(u + position, v + position, @color)
      }
    end
  end

end