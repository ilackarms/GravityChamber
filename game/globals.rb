class Globals
  def self.initialize window
   @game_objects ||= []
   @main_window = window
  end

  def self.main_window
    @main_window
  end

  def self.register_game_object(game_object)
    game_object.id = @game_objects.size
    @game_objects << game_object
  end

  def self.find_game_object_by_id id
    @game_objects[id]
  end

  def self.to_s
    @game_objects ||= []
    s = "Registered Game Objects:\n"
    @game_objects.each do |o|
      s += o.to_s + "\n"
    end
    return s
  end

end