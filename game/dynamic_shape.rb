module DynamicShape

  class Movable
    attr_accessor :shape
  end

  def zero_vector()
    CP::Vec2.new(0,0)
  end

  def create_dynamic_poly(x, y, mass, collision_tag)
    moment_of_inertia = CP.moment_for_circle(mass, 5,0, zero_vector)
    body = CP::Body.new(mass, moment_of_inertia)
    @shape = CP::Shape::Poly.new(body, @bounds)#CP::Shape::Circle.new(body, 5,zero_vector)
    @shape.collision_type = collision_tag
    @shape.body.p = CP::Vec2.new(x,y)
    @shape.e = elast if self.respond_to?("elast")
    @shape.u = fric if self.respond_to?("fric")
    @space.add_body(body) unless @fixed
    @space.add_shape(@shape)
    @color = 0xFFFFFF00
  end

  def draw_polygon(offset_x=0, offset_y=0)
    @bounds.each_cons(2) do |pair|
      a = @shape.body.local2world(pair.first)
      b = @shape.body.local2world(pair[1])
      @window.draw_line(a.x+offset_x, @window.height - a.y+offset_y, @color, b.x+offset_x, @window.height - b.y+offset_y, @color, z=1, mode=:default)
    end
    a = @shape.body.local2world(@bounds.last)
    b = @shape.body.local2world(@bounds.first)
    @window.draw_line(a.x+offset_x, @window.height - a.y+offset_y, @color, b.x+offset_x, @window.height - b.y+offset_y, @color, z=1, mode=:default)
  end

end