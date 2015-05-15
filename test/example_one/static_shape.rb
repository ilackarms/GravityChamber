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
    @shape.body.p = zero_vector
    @shape.body.a = 0
    @shape.e = elast if self.respond_to?("elast")
    @shape.u = fric if self.respond_to?("fric")
    @space.add_shape(@shape)
    @color = color
  end

  def create_static_box(x, y, collision_tag, color)
    moment_of_inertia, mass = infinity, infinity
    body = CP::Body.new(mass, moment_of_inertia)
    @shape = CP::Shape::Poly.new(body, @bounds)
    @shape.collision_type = collision_tag
    @shape.body.p = CP::Vec2.new(x,y)
    @shape.body.a = 0
    @shape.e = elast if self.respond_to?("elast")
    @shape.u = fric if self.respond_to?("fric")
    @space.add_body(body) unless @fixed
    @space.add_shape(@shape)
    @color = color
  end

  def draw_wall(offset_x=0, offset_y=0)
    a = @shape.body.local2world(@v1)
    b = @shape.body.local2world(@v2)
    @window.draw_line(a.x+offset_x, @window.height - a.y+offset_y, @color, b.x+offset_x, @window.height - b.y+offset_y, @color, z=1, mode=:default)
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

  private

  def start_vec
    zero_vector
  end

  def end_vec
    CP::Vec2.new(@length,0)
  end

end
