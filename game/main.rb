require 'rubygems'
require 'gosu'
require '../game/globals'
require '../game/game_object/game_object'
require '../game/physics/world_space'
require 'chipmunk'
require '../game/shapes/draw_shape'
require_relative '../game/shapes/draw_poly'
require_relative '../game/physics/shape_wrapper'
require_relative '../game/physics/static_shape_wrapper'


SUB_STEPS = 6
ZERO_VECTOR = CP::Vec2.new(0,0)
FPS = (1/60.0)


class Main < Gosu::Window

  attr_accessor :main_window, :space, :screen_height, :screen_width

  def initialize
    @screen_width = 640*2
    @screen_height = 480*2

    super @screen_width, @screen_height, false
    self.caption = 'RubyStone'

    #initialize model
    Globals.initialize self

    @space = Spaces::WorldSpace.new
    create_world
  end


  def update
    #game logic, called 60fps
    SUB_STEPS.times do
      @test_physics_body.update
      @test_physics_body2.update
      @space.step FPS
    end
  end

  def draw
    #@test_box.draw
    @test_physics_body.draw
    @test_physics_body2.draw
    @test_level_body.draw
  end

  def button_down(id)
    if id == Gosu::KbEscape
      puts "Closing window!"
      close
    end
    if id == Gosu::KbUp
      #@test_physics_body.shape.body.apply_force(CP::Vec2.new(0,500), ZERO_VECTOR)
      @test_physics_body.shape.body.v = CP::Vec2.new(0,10)
    end
    if id == Gosu::KbLeft
      #@test_physics_body.shape.body.apply_force(CP::Vec2.new(0,500), ZERO_VECTOR)
      @test_physics_body.shape.body.apply_force(CP::Vec2.new(-20,0), ZERO_VECTOR)
    end
    if id == Gosu::KbRight
      #@test_physics_body.shape.body.apply_force(CP::Vec2.new(0,500), ZERO_VECTOR)
      @test_physics_body.shape.body.apply_force(CP::Vec2.new(20,0), ZERO_VECTOR)
    end
  end

  def create_world
    box_points = [] << ZERO_VECTOR << CP::Vec2.new(0,40) << CP::Vec2.new(40,40) << CP::Vec2.new(40,0)
    @test_physics_body = ShapeWrapper.new(box_points, 10, CP::Vec2.new(40, @screen_height/2), 0.04, Gosu::Color::RED)
    @test_physics_body2 = ShapeWrapper.new(box_points, 10, CP::Vec2.new(40, @screen_height/2+100), 0.04, Gosu::Color::RED)

    floor_points = [] << ZERO_VECTOR << CP::Vec2.new(0,20) <<
        CP::Vec2.new(0,20) <<
        CP::Vec2.new(1200,20) <<
        CP::Vec2.new(1200,0)
        # CP::Vec2.new(40,40) <<
        # CP::Vec2.new(80,40) <<
        # CP::Vec2.new(80,60) <<
        # CP::Vec2.new(120,60) <<
        # CP::Vec2.new(120,120) <<
        # CP::Vec2.new(160,120) <<
        # CP::Vec2.new(160,0)

    @test_level_body = StaticShapeWrapper.new(floor_points, ZERO_VECTOR, 0, Gosu::Color::BLUE)
    # @test_level_body.shape.collision_type = :floor
    # @test_physics_body.shape.collision_type = :floor
    # @test_physics_body2.shape.collision_type = :floor

    #@space.gravity = CP::Vec2.new(0,-9.81)
    @space.damping = 0.9
    @space.add_body @test_physics_body.shape.body
    @space.add_body @test_physics_body2.shape.body
    @space.add_static_shape @test_level_body.shape

  end

  def self.start
    $window = Main.new
    $window.show
  end

end

Main.start