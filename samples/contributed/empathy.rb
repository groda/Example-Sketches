# Empathy
# original by Kyle McDonald
# http://www.openprocessing.org/visuals/?visualID=1182

# This sketch takes advantage of multiple processors by running calculations
# in a separate thread.

CELL_COUNT      = 5000
SLOW_DOWN       = 0.97
ROTATION        = 0.004
LINE_LENGTH     = 37
MULTI_THREADED  = true

attr_reader :cells

def setup
  size(500, 500, P2D)
  stroke(0, 0, 0, 25)
  initialize_cells
  start_cell_updates if MULTI_THREADED
end

def initialize_cells
  @cells  = []
  n = CELL_COUNT
  n.times do |i|
    a = i + rand(PI / 9.0)
    r = ((i / n.to_f) * (width / 2) * (((n - i) / n.to_f) * 3.3)) + rand(6.0)
    cells << Cell.new((r * cos(a) + width / 2).to_i, (r * sin(a) + height / 2).to_i)
  end
end

def start_cell_updates
  Thread.new { Kernel.loop { cells.each(&:update) } }
end

def draw
  background 255
  cells.each(&:sense) if started?
end

def started?
  pmouse_x != 0 || pmouse_y != 0
end

def mouse_pressed
  cells.each(&:reset)
end

##
# The cell responds to mouse movement
##
class Cell
  attr_reader :x, :y, :spin, :angle
  def initialize(x, y)
    @x, @y  = x, y
    reset
  end

  def reset
    @spin, @angle = 0, 0
  end

  def update
    det = ((pmouse_x - x) * (mouse_y - y) - (mouse_x - x) * (pmouse_y - y)).to_f
    @spin += ROTATION * det / dist(x, y, mouse_x, mouse_y).to_f
    @spin *= SLOW_DOWN
    @angle += spin
  end

  def sense
    update unless MULTI_THREADED
    d = LINE_LENGTH * spin + 0.001
    line(x, y, x + d * cos(angle), y + d * sin(angle))
  end
end
