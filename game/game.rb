require 'rubygems'
require 'gosu'
require 'chipmunk'
#require_relative 'lib/chipmunk.so'
require_relative 'player'
require_relative 'wall'
require_relative 'kill_zone'
require_relative 'goal_zone'
require_relative 'power_up'
require_relative 'trigger_object'
require_relative 'movable_poly'
require_relative 'block'
require_relative 'kill_block'
require_relative 'timer'
include Gosu

class Game < Window
  PHYSICS_RESOLUTION = 50
  PHYSICS_TIME_DELTA = 1.0/350.0
  VISCOUS_DAMPING = 1
  GRAVITY = -30.0
  X_RES = 800
  Y_RES = 600

  DEBUG_MODE = false

  def initialize
    super(X_RES, Y_RES, false)
    @current_level = 0
    @time_text = Gosu::Font.new(self, "Courier", 16)
    init_and_refresh_level
  end

  def init_and_refresh_level
    @space = CP::Space.new
    @space.damping = VISCOUS_DAMPING
    @space.gravity = CP::Vec2.new(0,GRAVITY)
    #initialize safe deletion array
    @safe_removal_array = []

    Timer.kill_all_threads

    @special_draw_instructions = []
    @special_behaviors = []
    load_level @current_level

    if DEBUG_MODE
      @debug_force_lines = []
    end

    #set window title
    self.caption = "Gravity Chamber ##{@current_level}: #{@level_name}"

    #add collision functions
    ##collision function for player and ground -> allow player to be grounded while touching wall
    @space.add_collision_func :player, :wall do |player_shape, wall_shape|
      player = player_shape.object
      player.is_grounded = 500
      true
    end

    #add collision functions
    ##collision function for player and ground -> allow player to be grounded while touching blocks too
    @space.add_collision_func :player, :movable_block do |player_shape, wall_shape|
      player = player_shape.object
      player.is_grounded = 500
      true
    end

    @space.add_collision_func :player, :kill_zone do |player_shape, kill_zone_shape|
      @player.kill
      if kill_zone_shape.object != nil and kill_zone_shape.object.is_a? KillBlock
        kill_zone_shape.object.destroy
      end
      Timer.call_repeating(lambda{ @special_behaviors << lambda { init_and_refresh_level}}, 0.24, 1)
      false
    end

    @space.add_collision_func :kill_zone , :kill_zone do |kill_zone_shape_1, kill_zone_shape_2|
      if kill_zone_shape_1.object != nil and kill_zone_shape_1.object.is_a? KillBlock
        kill_zone_shape_1.object.destroy
        Timer.call_repeating(lambda{@special_behaviors << lambda { safe_remove kill_zone_shape_1.object}}, 0.24, 1)
      end
      if kill_zone_shape_2.object != nil and kill_zone_shape_2.object.is_a? KillBlock
        kill_zone_shape_2.object.destroy
        Timer.call_repeating(lambda{@special_behaviors << lambda { safe_remove kill_zone_shape_2.object}}, 0.24, 1)
      end
      false
    end

    @space.add_collision_func :player, :goal_zone do |player_shape, goal_zone_shape|
      @current_level += 1
      @player.kill goal_zone_shape.object.color
      Timer.call_repeating(lambda{ @special_behaviors << lambda { init_and_refresh_level}}, 0.24, 1)
      false
    end

    @space.add_collision_func :player, :attractor_power do |player_shape, powerup_shape|
      @player.activate_powerup :attractor_power, powerup_shape.object.max_uses
      safe_remove(powerup_shape.object)
      false
    end

    @space.add_collision_func :player, :repulsion_power do |player_shape, powerup_shape|
      @player.activate_powerup :repulsion_power, powerup_shape.object.max_uses
      safe_remove(powerup_shape.object)
      false
    end

    #trigger collision. can be visible/invisible. trigger.object is a lambda
    #special behaviors is in object[0], special draw instructions are in object[1]
    #nil if no instruction
    @space.add_collision_func :player, :trigger do |player_shape, trigger_shape|
      if trigger_shape.object[0] != nil
        @special_behaviors << trigger_shape.object[0]
      end
      if trigger_shape.object[1] != nil
        @special_draw_instructions << trigger_shape.object[1]
      end
      @special_draw_instructions
      safe_remove(trigger_shape.object[2])
      false
    end
    #trugger collision for movable blocks (flip switches with blocks)
    @space.add_collision_func :block, :trigger do |block_shape, trigger_shape|
      if trigger_shape.object[0] != nil
        @special_behaviors << trigger_shape.object[0]
      end
      if trigger_shape.object[1] != nil
        @special_draw_instructions << trigger_shape.object[1]
      end
      @special_draw_instructions
      safe_remove(trigger_shape.object[2])
      false
    end
  end

  def define_levels
    level_array = []

    #level 0
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,1]
      points << [10,1]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 600, 400)
      @player = Player.new(self, @space, 40, 100)
      @special_behaviors = []
      @special_behaviors << lambda {
        @text = Gosu::Font.new(self, "Courier", 36)
      }
      @special_draw_instructions = []
      @special_draw_instructions << lambda {
        @text.draw('GRAVITY CHAMBER', X_RES/2 - 150, 50, 0, 1, 1, Gosu::Color::YELLOW)
      }
      @level_name = 'Title'
    }

    #level 1
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,1]
      points << [3,1]
      points << [3,1.5]
      points << [5,1.5]
      points << [5,3]
      points << [6,3]
      @game_objects += construct_walls(points)
      points = []
      points << [6.65,3]
      points << [10,3]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 600, 400)
      @player = Player.new(self, @space, 40, 100)
      @level_name = 'Jump'
    }

    #level 2
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,1]
      points << [2,1]
      points << [2,2]
      points << [3.6,2]
      points << [3.6,5]
      @game_objects += construct_walls(points)
      points = []
      points << [3,4.5]
      points << [3,9]
      @game_objects += construct_walls(points)
      points = []
      points << [3.7,8]
      points << [7,8]
      @game_objects += construct_walls(points)
      points = []
      points << [8,8]
      points << [10,8]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 700, 600)
      @player = Player.new(self, @space, 40, 100)
      @level_name = 'Climb'
    }

    #level 3
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,4]
      points << [1.3,4]
      points << [1.3,4.25]
      points << [2.1,4.25]
      points << [2.1,4]
      points << [3.1,4]
      @game_objects += construct_walls(points)
      points = []
      points << [7,4]
      points << [9,4]
      points << [9,5.3]
      points << [9.3,5.3]
      points << [9,5.3]
      points << [9,4]
      points << [10,4]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 750, 250)
      trigger_follow = PowerUp.new(self, @space, 130, 350, :attractor_power, 0xFF66FF33, 1)
      @game_objects << trigger_follow

      #define lambdas (0 = non-draw behaviors, 1 = draw behaviors)
      special_lambdas = []
      special_lambdas << lambda {
        @text = Gosu::Font.new(self, "Courier", 36)
      }
      special_lambdas << lambda {
        @text.draw("CLICK", X_RES/2 - 50, 50, 0, 1, 1, Gosu::Color::GRAY)
      }
      #####

      @game_objects << TriggerObject.new(self, @space, 120, 250, 15, 15, special_lambdas, trigger_follow)
      @player = Player.new(self, @space, 40, 250)
      @level_name = 'Float'
    }

    #level 4
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,2]
      points << [1.3,2]
      points << [1.3,2.25]
      points << [2.1,2.25]
      points << [2.1,2]
      points << [6,2]
      @game_objects += construct_walls(points)
      points = []
      points << [6,7]
      points << [9,7]
      points << [9,8.3]
      points << [9.3,8.3]
      points << [9,8.3]
      points << [9,7]
      points << [10,7]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 750, 500)

      trigger_follow = PowerUp.new(self, @space, 130, 350, :attractor_power, 0xFF66FF33, 1)
      @game_objects << trigger_follow

      #define lambdas (0 = non-draw behaviors, 1 = draw behaviors)
      special_lambdas = []
      special_lambdas << lambda {
        @text = Gosu::Font.new(self, "Courier", 36)
      }
      special_lambdas << lambda {
        @text.draw("RIGHT CLICK TO DISMISS", X_RES/2 - 280, 50, 0, 1, 1, Gosu::Color::GRAY)
      }
      #####

      @game_objects << TriggerObject.new(self, @space, 120, 250, 15, 15, special_lambdas, trigger_follow)

      @player = Player.new(self, @space, 40, 250)
      @level_name = 'Launch'
    }

    #level 5
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,3]
      points << [1.35,3]
      @game_objects += construct_walls(points)
      points = []
      points << [3,3]
      points << [3,1]
      points << [4.75,1]
      points << [4.75,1.5]
      points << [5,1.5]
      points << [4.75,1.5]
      points << [4.75,1]
      points << [6,1]
      points << [6,3]
      @game_objects += construct_walls(points)
      points = []
      points << [7, 5]
      points << [9.1, 7]
      points << [10,7]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 728, 500)
      @game_objects << PowerUp.new(self, @space, 100, 350, :attractor_power, 0xFF66FF33, 1)

      @player = Player.new(self, @space, 30, 250)
      @level_name = 'Hurry'
    }

    #level 6
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      (0..10).each do
      |n|
        points << [n * 0.7, 8 - n * 0.7 + 0.7]
        points << [n * 0.7, 8 - n * 0.7]
      end
      points << [11 * 0.7, 8 - 11 * 0.7 + 0.7]
      @game_objects += construct_walls(points)
      points = []
      points << [7.5,8]
      points << [10,8]
      @game_objects += construct_walls(points)
      points = []
      points << [7,9.5]
      points << [7,2.5]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 750, 500)
      @game_objects << PowerUp.new(self, @space, 130, 450, :attractor_power, 0xFF66FF33, 2)
      @player = Player.new(self, @space, 40, 500)
      @level_name = 'Tricky 1'
    }

    #level 7
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,1]
      points << [0.5,1]
      points << [0.5,1.25]
      points << [0.8,1.25]
      points << [0.8,1]
      points << [1.2,1]
      @game_objects += construct_walls(points)
      points = []
      points << [5,7]
      points << [5,8.3]
      points << [5.3,8.3]
      points << [5,8.3]
      points << [5,7]
      points << [6.5,7]
      points << [6.5,8.3]
      points << [6.2,8.3]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 450, 500)
      @game_objects << PowerUp.new(self, @space, 50, 350, :attractor_power, 0xFF66FF33, 2)
      @player = Player.new(self, @space, 20, 250)
      @level_name = 'Slingshot'
    }

    #level 8
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,4]
      points << [2.5,4]
      @game_objects += construct_walls(points)
      points = []
      points << [7.5,4]
      points << [10,4]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,6.75]
      points << [100,6.75]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [-100,2.25]
      points << [100,2.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 700, 300)
      @game_objects << PowerUp.new(self, @space, 150, 300, :repulsion_power, 0xFFC680FF, 1)
      @player = Player.new(self, @space, 20, 300)
      @level_name = 'Push'
    }

    #level 9
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,5]
      points << [2.5,5]
      @game_objects += construct_walls(points)
      points = []
      points << [7.5,5]
      points << [10,5]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,9.95]
      points << [5,9.95]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [5,9.95]
      points << [5,3]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 700, 550)
      @game_objects << PowerUp.new(self, @space, 150, 550, :repulsion_power, 0xFFC680FF, 1)
      @player = Player.new(self, @space, 20, 550)
      @level_name = 'V'
    }

    #level 10
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,5]
      points << [1.5,5]
      @game_objects += construct_walls(points)
      points = []
      points << [7.5,5]
      points << [10,5]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,9.95]
      points << [6,9.95]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [6,9.95]
      points << [6,3]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [3,7.95]
      points << [3,0]
      @game_objects += construct_connected_kill_zones(points)
      @player = Player.new(self, @space, 20, 550)
      @game_objects << PowerUp.new(self, @space, 100, 550, :repulsion_power, 0xFFC680FF, 2)
      @game_objects << GoalZone.new(self, @space, 700, 550)
      @level_name = 'N'
    }

    #level 11
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,9]
      points << [2.5,9]
      @game_objects += construct_walls(points)
      points = []
      points << [7.5,9]
      points << [10,9]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,9.95]
      points << [100,9.95]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 700, 550)
      @game_objects << PowerUp.new(self, @space, 150, 550, :attractor_power, 0xFF66FF33, 1)
      @player = Player.new(self, @space, 20, 550)
      @level_name = 'U'
    }

    #level 12
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,2]
      points << [3,2]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [3,2]
      points << [3,4]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [3,4]
      points << [5,4]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [5,4]
      points << [5,6]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [5,6]
      points << [6,6]
      points << [6,6.25]
      points << [6,6]
      points << [7,6]
      @game_objects += construct_walls(points)
      points = []
      points << [7,6]
      points << [7,7]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [7,7]
      points << [10,7]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 750, 550)
      @game_objects << PowerUp.new(self, @space, 130, 250, :attractor_power, 0xFF66FF33, 1)
      # @game_objects << Block.new(self, @space, 650, 350, 15, 50, 100)
      #special behaviors: generate lots of blcoks, have to pile them up!
      @player = Player.new(self, @space, 40, 250)
      @level_name = 'Slide'
    }

    #level 13
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0.01,12]
      points << [0.01,9]
      points << [2.5,9]
      @game_objects += construct_walls(points)
      points = []
      points << [2.5,9]
      points << [2.5,2]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [0.1,3]
      points << [0.1,1]
      points << [0.5,1]
      points << [0.5,2]
      points << [0.4,2]
      points << [0.5,2]
      points << [0.5,1]
      points << [2,1]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 20, 150)
      @game_objects << PowerUp.new(self, @space, 150, 550, :attractor_power, 0xFF66FF33, 2)
      @player = Player.new(self, @space, 20, 550)
      @level_name = 'Stacking'
    }

    #level 14
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0.01,3]
      points << [0.01,2]
      points << [3,2]
      @game_objects += construct_walls(points)
      points = []
      # points << [6.5,3]
      # points << [7.5,2.5]
      # points << [7.75,3.5]
      # points << [7.5,2.5]
      # points << [8.5,2]
      points << [6.5,2]
      points << [8,2]
      @game_objects += construct_walls(points)
      points = []
      points << [6.58,4.5]
      points << [6.5,3.75]
      points << [6.5,2]
      # points << [6.5,3]
      # points << [5,5]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [6.58,4.5]
      points << [8,4.5]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 540, 200)
      @game_objects << PowerUp.new(self, @space, 150, 150, :attractor_power, 0xFF66FF33, 3)
      @player = Player.new(self, @space, 20, 150)
      @level_name = 'Stacking 2'
    }

    #level 15
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,5]
      points << [0.4,5]
      points << [0.4,5.2]
      points << [0.4,5]
      points << [1.25,5]
      @game_objects += construct_walls(points)
      points = []
      points << [8,4.9]
      points << [10,4.9]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,4.25]
      points << [100,4.25]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [-100,6.5]
      points << [100,6.5]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 740, 350)
      @game_objects << PowerUp.new(self, @space, 75, 350, :repulsion_power, 0xFFC680FF, 2)
      @player = Player.new(self, @space, 20, 350)
      @level_name = 'Rail Gun'
    }

    #level 16
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,1]
      points << [2.5,1]
      @game_objects += construct_walls(points)
      points = []
      points << [3.5,0]
      points << [3.5,3]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [0,2]
      points << [1.8,2]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [2,1.5]
      points << [2,4]
      @game_objects += construct_walls(points)
      points = []
      points << [2.2,4]
      points << [4,4]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [5.5,2]
      points << [5.5,5]
      @game_objects += construct_walls(points)
      points = []
      points << [5.3,5.5]
      points << [3.5,5.5]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [3,4.5]
      points << [3,8]
      @game_objects += construct_walls(points)
      points = []
      points << [6,0]
      points << [6,7]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [6.5,9.5]
      points << [6.5,7]
      @game_objects += construct_walls(points)
      points = []
      points << [5.3,8.25]
      points << [1.5,8.25]
      @game_objects += construct_connected_kill_zones(points)
      points = []
      points << [1.5,9.5]
      points << [1.5,8.5]
      points << [0.1,8.5]
      points << [0.1,10]
      @game_objects += construct_walls(points)
      points = []
      points << [-100,0.1]
      points << [100,0.1]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 100, 550)
      @game_objects << PowerUp.new(self, @space, 75, 100, :attractor_power, 0xFF66FF33, 2)
      @player = Player.new(self, @space, 20, 100)
      @level_name = 'Wall Jumper'
    }

    #level 17
    level_array << lambda {
      @blocks = []
      @game_objects = []
      points = []
      points << [0,1.5]
      points << [10,1.5]
      @game_objects += construct_frictionless_wall(points)
      points = []
      points << [-100,0.25]
      points << [100,0.25]
      @game_objects += construct_connected_kill_zones(points)
      @game_objects << GoalZone.new(self, @space, 450, 350)
      @game_objects << PowerUp.new(self, @space, 130, 550, :attractor_power, 0xFF66FF33, 1)
      # @game_objects << Block.new(self, @space, 650, 350, 15, 50, 100)
      #special behaviors: generate lots of blcoks, have to pile them up!
      Timer.call_repeating(lambda{
                             @special_behaviors = []
                             @special_behaviors << lambda {@game_objects << KillBlock.new(self, @space, 150, 350, 20, 15, 80)}
                             @special_behaviors << lambda {@game_objects << KillBlock.new(self, @space, 250, 350, 20, 15, 80)}
                             @special_behaviors << lambda {@game_objects << KillBlock.new(self, @space, 350, 350, 20, 15, 80)}}, 1, 12)
      @player = Player.new(self, @space, 40, 550)
      @level_name = 'Hops'
    }
    
    level_array
  end

  def safe_remove game_object
    @game_objects.delete(game_object)
    @safe_removal_array << game_object
  end

  def attract_all_towards_point p, magnitude
    all_bodies = []
    all_bodies += @game_objects
    all_bodies << @player
    @debug_force_lines = []
    all_bodies.each do
      |dynamic_shape|
      if dynamic_shape.is_a?(DynamicShape::Movable)
        body_pos = dynamic_shape.shape.body.p
        # dynamic_shape.shape.body.apply_impulse((), zero_vector)
        dynamic_shape.apply_impulse((p - body_pos) * magnitude  / (p.dist(body_pos)**2))
        if DEBUG_MODE
          @debug_force_lines << [p, body_pos]
        end
      end
    end
  end

  def load_level index
    define_levels[index].call
  end

  def construct_walls points
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

  def construct_frictionless_wall points
    wall_list = []
    points.each_with_index  do
    |point, index|
      if index == points.size - 1
        break
      end
      p1 = point
      p2 = points[index + 1]
      x_unit = Game::X_RES / 10
      y_unit = Game::Y_RES / 10
      wall = Wall.new(self, @space, CP::Vec2.new(x_unit * p1[0],y_unit * p1[1]), CP::Vec2.new(x_unit * p2[0],y_unit * p2[1]))
      wall.shape.u = 0
      wall.color = 0xFF70FFFD
      if p1[0] == p2[0]
        wall.shape.collision_type = :vertical_frictionless_wall
      end
      wall_list << wall
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

  def update
    PHYSICS_RESOLUTION.times do |repeat|
      @space.step(PHYSICS_TIME_DELTA)
      @player.update
    end
    @safe_removal_array.each do
      |obj|
      #3rd index is the object itself
      @space.remove_shape(obj.shape)
      @safe_removal_array.delete(obj)
    end
    @special_behaviors.each do
      |behavior|
      behavior.call
      @special_behaviors.delete(behavior)
    end
  end

  def draw
    offset_x = 0 #-1 * @player.shape.body.p.x + 200
    offset_y = 0 #@player.shape.body.p.y - 400
    @blocks.each{|block| block.draw offset_x, offset_y}
    @game_objects.each{|wall| wall.draw offset_x, offset_y}
    @player.draw offset_x, offset_y
    elapsed_time = (Gosu.milliseconds / 1000.0)
    @time_text.draw('time: '+ "%.1f" % elapsed_time, X_RES - 150, 25, 0, 1, 1, Gosu::Color::GRAY)
    @special_draw_instructions.each do
      |instruction|
      instruction.call
    end
    if DEBUG_MODE
      @debug_force_lines.each do
        |pair|
        p1 = pair[0]
        p2 = pair[1]
        draw_line(p1.x + offset_x, height - p1.y + offset_y, Gosu::Color::RED, p2.x + offset_x, height - p2.y + offset_y, Gosu::Color::BLUE)
      end
    end
  end

  def button_down(id)
    if id == Button::KbEscape then close end
    if id == Button::KbF1 then
      init_and_refresh_level
    end
    @player.handle_button_down id
  end

  def award_points points
    @points += points
  end

end

if not defined?(Ocra)
  window = Game.new
  window.show
end
