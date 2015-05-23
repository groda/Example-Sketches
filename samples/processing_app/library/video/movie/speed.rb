#
# Speed.
#
# Use the Movie.speed method to change
# the playback speed.
#
#

load_library :video
include_package 'processing.video'

attr_reader :mov

def setup
  size(640, 360)
  background(0)
  @mov = Movie.new(self, 'transit.mov')
  mov.loop
end

def draw
  image(mov, 0, 0)
  begin
    mov.read
  end if mov.available?

  new_speed = map1d(mouse_x, (0..width), (0.1..2))
  mov.speed(new_speed)

  fill(255)
  text(format('%.2fX', new_speed), 10, 30)
end
