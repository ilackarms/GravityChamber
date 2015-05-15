require 'rubygems'
require 'gosu'
require 'chipmunk'
require_relative 'player'
require_relative 'wall'
require_relative 'kill_zone'
require_relative 'goal_zone'
include Gosu

class Game < Window
  PHYSICS_RESOLUTION = 50
  PHYSICS_TIME_DELTA = 1.0/350.0
  VISCOUS_DAMPING = 0.7
  GRAVITY = -30.0
  X_RES = 640
  Y_RES = 480

  attr_accessor :walls

  def initialize
    super(X_RES, Y_RES, false)
    @current_level = 0
    init_and_refresh_level
  end

  def init_and_refresh_level
    self.caption = "The Elusive Mr. Wimbly"
    @space = CP::Space.new
    @space.damping = VISCOUS_DAMPING
    @space.gravity = CP::Vec2.new(0,GRAVITY)

    load_level @current_level

    #add collision functions
    ##collision function for player and ground -> allow player to be grounded while touching wall
    @space.add_collision_func :player, :wall do |player_shape, wall_shape|
      player = player_shape.object
      player.is_grounded = 500
      true
    end

    @space.add_collision_func :player, :kill_zone do |player_shape, kill_zone_shape|
      init_and_refresh_level
      false
    end

    @space.add_collision_func :player, :goal_zone do |player_shape, goal_zone_shape|
      @current_level += 1
      init_and_refresh_level
      false
    end

  end

  def load_level index
    levels[index].call
  end

  def levels
    level_array = []
    #level 1
    level_array << lambda {
      @blocks = []
      @walls = []
      points = []
      points << [0,1]
      points << [3,1]
      points << [3,2]
      points << [5,2]
      points << [5,4]
      points << [6,4]
      @walls += construct_connected_walls(points)
      points = []
      points << [7,4]
      points << [10,4]
      @walls += construct_connected_walls(points)

      points = []
      points << [-10,0.25]
      points << [10,0.25]
      @walls += construct_connected_kill_zones(points)
      @walls << GoalZone.new(self, @space, 600, 400)
      @player = Player.new(self, @space, 40, 100)
    }

    level_array << lambda {
      @blocks = []
      @walls = []
      points = []
      points << [0,1]
      points << [2,1]
      points << [2,2]
      points << [4,2]
      points << [4,5]
      @walls += construct_connected_walls(points)
      points = []
      points << [3.1,4.5]
      points << [3,9]
      @walls += construct_connected_walls(points)
      points = []
      points << [4,8]
      points << [7,8]
      @walls += construct_connected_walls(points)
      points = []
      points << [8,8]
      points << [10,8]
      @walls += construct_connected_walls(points)
      points = []
      points << [-10,0.25]
      points << [10,0.25]
      @walls += construct_connected_kill_zones(points)
      @walls << GoalZone.new(self, @space, 600, 600)
      @player = Player.new(self, @space, 40, 100)
    }
    level_array
  end

  def attract_all_towards_point p, magnitude
    all_bodies = []
    all_bodies += @walls
    all_bodies << @player
    all_bodies.each do
      |dynamic_shape|
      if dynamic_shape.is_a?(DynamicShape::Movable)
        body_pos = dynamic_shape.shape.body.p
        dynamic_shape.shape.body.apply_force((p - body_pos)*magnitude / (p.dist(body_pos)**2), zero_vector)
      end
    end
  end

  def update
    PHYSICS_RESOLUTION.times do |repeat|
      @space.step(PHYSICS_TIME_DELTA)
      @player.update
    end
  end

  def draw
    @blocks.each{|block| block.draw}
    @walls.each{|wall| wall.draw}
    @player.draw
  end

  def more_blocks
    @blocks << Block.new(self, @space, X_RES/2.0 + (rand(100)/100.0), Y_RES - 400)
  end

  def button_down(id)
    if id == Button::KbEscape then close end
    if id == Button::KbSpace then more_blocks end
    if id == Button::KbF1 then
      init_and_refresh_level
    end
    @player.handle_button_down id
  end

  def construct_connected_walls points
    wall_list = []
    points.each_with_index  do
      |point, index|
      if index == points.size - 1
        break
      end
      p1 = point
      p2 = points[index + 1]
      x_unit = X_RES / 10
      y_unit = Y_RES / 10
      wall_list << Wall.new(self, @space, CP::Vec2.new(x_unit * p1[0],y_unit * p1[1]), CP::Vec2.new(x_unit * p2[0],y_unit * p2[1]))
    end
    wall_list
  end

  def construct_connected_kill_zones points
    kill_zones = []
    points.each_with_index  do
      |point, index|
      if index == points.size - 1
        break
      end
      p1 = point
      p2 = points[index + 1]
      x_unit = X_RES / 10
      y_unit = Y_RES / 10
      kill_zones << KillZone.new(self, @space, CP::Vec2.new(x_unit * p1[0],y_unit * p1[1]), CP::Vec2.new(x_unit * p2[0],y_unit * p2[1]))
    end
    kill_zones
  end

end

window = Game.new
window.show