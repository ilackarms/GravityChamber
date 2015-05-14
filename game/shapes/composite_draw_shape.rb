class CompositeDrawShape < DrawShape
  attr_accessor :components

  #default draw for composite draw shapes
  def draw
    for shape in @components
      shape.draw
    end
  end
end