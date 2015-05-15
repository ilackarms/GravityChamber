module StaticShape

  def zero_vector()
    CP::Vec2.new(0,0)
  end

  def infinity
    return 1/0.0
  end

  def create_static_line(v1, v2, collision_tag, color)
    moment_of_inertia, mass = infinity, infinity
    body = CP::Body.new(mass, moment_of_inertia)
    @v1 = v1
    @v2 = v2
    @shape = CP::Shape::Segment.new(body, @v1, @v2, 0)
    @shape.collision_type = collision_tag
    @shape.body.p = zero_vector #CP::Vec2.new((v1.x+v2.x)/2,(v1.y+v2.y)/2)
    @shape.body.a = 0
    @shape.e = elast if self.respond_to?("elast")
    @shape.u = fric if self.respond_to?("fric")
    @space.add_shape(@shape)
    @color = color
  end

  def draw_wall(offset_x=0, offset_y=0)
    a = @shape.body.local2world(@v1)
    b = @shape.body.local2world(@v2)
    @window.draw_line(a.x+offset_x, @window.height - a.y+offset_y, @color, b.x+offset_x, @window.height - b.y+offset_y, @color, z=1, mode=:default)
  end

  private

  def start_vec
    zero_vector
  end

  def end_vec
    CP::Vec2.new(@length,0)
  end

end
