class DrawLine < DrawShape

  def initialize v1, v2, color
    @vertex_list = [] << v1 << v2
    @color = color
  end

  def update v1, v2, color
    @vertex_list = [] << v1 << v2
    @color = color
  end

  def draw
    v1 = @vertex_list[0]
    v2 = @vertex_list[1]
    Globals.main_window.draw_line v1.x, Globals.main_window.screen_height - v1.y, color, v2.x, Globals.main_window.screen_height - v2.y, color
  end
end