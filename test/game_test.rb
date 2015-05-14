require "../game/main"
require "test/unit"

class GameTest < Test::Unit::TestCase

  def setup
  end

  def test_init

    window = Main.new

    #assert Globals has been initialized
    assert_not_nil(Globals)

    g1 = GameObject.new("Basic GameObject A")
    g2 = GameObject.new("Basic GameObject B")

    game_obj_a = Globals.find_game_object_by_id(0)
    game_obj_b = Globals.find_game_object_by_id(1)

    assert_equal(g1, game_obj_a)
    assert_equal(g2, game_obj_b)

  end

end