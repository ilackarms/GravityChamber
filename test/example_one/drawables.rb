require 'gosu'
require 'chipmunk'

module Drawable
  class Circle

    attr_reader :columns, :rows

    def initialize window
      @window = window
      @points = []
      i = 0
      64.times do
        i += 1
        angle = 3.14/64 * i
        @points << CP::Vec2.new(Math::cos(angle), Math::sin(angle))
      end
      points = []
      @points.each do
      |point|
        new_p = point * 25
        new_p.x += 50
        new_p.y += 50
        points << new_p
      end
    end

    def draw x, y, radius, color
      @color = color
      points = []
      @points.each do
        |point|
        new_p = point * radius * -1
        new_p.x += x
        new_p.y += y
        points << new_p
      end
      @points.each do
        |point|
        new_p = point * radius
        new_p.x += x
        new_p.y += y
        points << new_p
      end
      draw_polygon points
    end

    def draw_polygon(points, offset_x=0, offset_y=0)
      points.each_cons(2) do |pair|
        a = pair.first
        b = pair[1]
        @window.draw_line(a.x+offset_x, a.y+offset_y, @color, b.x+offset_x, b.y+offset_y, @color, z=1, mode=:default)
      end
      # a = points.last
      # b = points.first
      # @window.draw_line(a.x+offset_x, a.y+offset_y, @color, b.x+offset_x, b.y+offset_y, @color, z=1, mode=:default)
    end

  end

  class ShootingParticle
    attr_accessor :finished

    def initialize window, start, stop, color
      @window = window
      @start = start
      @stop = stop
      @color = color
      @current_start = start
      @current_stop = stop
    end

    def draw
      @current_start = @current_start.lerpconst(@stop, 4.5)
      @current_stop = @current_start.lerpconst(@stop, 4.5)
      @window.draw_line(@current_start.x, @current_start.y, @color, @current_stop.x, @current_stop.y, @color)
      if @current_start.dist(@stop) < 0.1
        @finished = true
      end
    end
  end

  class AttractorParticleSystem < Circle
    def initialize window
      super window
      @particles = []
    end

    def draw_special x, y, radius, color
      start_points = []
      @points.each do
      |point|
        new_p_start = point * radius * -10
        new_p_start.x += x
        new_p_start.y += y
        start_points << new_p_start
      end
      @points.each do
      |point|
        new_p_start = point * radius * 10
        new_p_start.x += x
        new_p_start.y += y
        start_points << new_p_start
      end

      if @particles.size < 6
        index = rand(0..start_points.size-1)
        @particles << ShootingParticle.new(@window, start_points[index], CP::Vec2.new(x,y), color)
      end

      @particles.each do
        |particle|
        if particle.finished
          @particles.delete(particle)
        end
        particle.draw
      end
    end
  end
end