require 'rubygems'
require 'gosu'
require 'chipmunk'
require_relative 'player'
require_relative 'block'
require_relative 'wall'
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
    setup_gosu_and_chipmunk
    load_level
  end

  def setup_gosu_and_chipmunk
    self.caption = "REALLY BORING!!!"
    @space = CP::Space.new
    @space.damping = VISCOUS_DAMPING
    @space.gravity = CP::Vec2.new(0,GRAVITY)

    #add collision functions
    ##collision function for player and ground -> allow player to be grounded while touching wall
    @space.add_collision_func :player, :wall do |player_shape, wall_shape|
      player = player_shape.object
      player.is_grounded = 500
      true
    end
  end

  def load_level
    @blocks = []
    @walls = []
    points = []
    points << [0,1]
    points << [3,1]
    points << [3,2]
    points << [5,2]
    points << [5,4]
    points << [7,4]
    @walls += construct_level(points)
    @player = Player.new(self, @space, 40, 100)
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
      setup_gosu_and_chipmunk
      load_level
    end
    @player.handle_jumping id
  end

  def make_wall(p1, p2)
    x_unit = X_RES / 10
    y_unit = Y_RES / 10
    Wall.new(self, @space, CP::Vec2.new(x_unit * p1[0],y_unit * p1[1]), CP::Vec2.new(x_unit * p2[0],y_unit * p2[1]))
  end

  def construct_level points
    wall_list = []
    points.each_with_index  do
      |point, index|
      if index == points.size - 1
        break
      end
      p1 = point
      p2 = points[index + 1]
      wall_list << make_wall(p1, p2)
    end
    wall_list
  end
end

window = Game.new
window.show