class GameObject
  attr_accessor :name, :id

  def initialize name
    @name = name
    Globals.register_game_object(self)
  end

  def to_s
    "Game Object ##{@id}: #{@name}"
  end

end