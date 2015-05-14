#!/usr/bin/env ruby
# Author : Emad Elsaid (https://github.com/blazeeboy)
require 'gosu'
include Gosu

$dimension = 1024
$line_limit = 70

class GameWindow < Window

  def initialize
    super $dimension, $dimension, false
    self.caption = "Drawing board"
    @points = []
  end

  def update
    @points << [ mouse_x, mouse_y ]
    @points.shift if @points.size > $line_limit
  end

  def draw
    return if @points.empty?
    @points.inject(@points[0]) do |last, point|
      draw_line	last[0],last[1], Color::WHITE,
                 point[0],point[1], Color::WHITE
      point
    end
  end

end
GameWindow.new.show
