require "securerandom"
load_library :vecmath
def setup
  # generate a few birds
  size 800, 800
  @flock = Flock.new(10, rand(800), rand(800))
  fill 255
end

def draw
  background 0
  #@flock.birds.each do |b|
    #b.steer(@flock.birds)
  #end
  @flock.birds.each(&:draw)
end


class Flock
  attr_reader :birds
  def initialize(bird_count, x, y)
    @birds = Array.new(bird_count) { Bird.new(x + rand(-50..50), y + rand(-50..50), nil) }
  end
end

# track position
# heading
# velocity/speed -- probably static
# find their neighbors -- Birds do this or something else does it?
# calculate new heading
#    - steer to avoid neighbors
#    - steer to average heading of neighbors
#    - steer toward average position of neighbors
# render itself -- generate a triangle pointing in the right direction
# and at the right position -- maybe to start each bird is represented by a circle?
class Bird
  attr_reader :position, :velocity

  def initialize(x,y,heading)
    @position = Vec2D.new(x,y)
    @velocity = Vec2D.new
  end

  def neighbor_radius
    30
  end

  def find_heading
  end

  def steer(flockmates)
    too_close_neighbors = flockmates.select do |bird|
      (bird.x - x).abs < neighbor_radius && (bird.y - y).abs < neighbor_radius
    end.reject { |b| b.equal?(self) }

    if too_close_neighbors.any?
      avg = [too_close_neighbors.map(&:x).reduce(:+)/too_close_neighbors.count,
             too_close_neighbors.map(&:y).reduce(:+)/too_close_neighbors.count]
      puts avg
    else
      @velocity = velocity_toward(mouse_x, mouse_y)
    end
  end

  def max_speed
    5
  end

  def mouse_heading
    Vec2D.new(mouse_x, mouse_y)
  end

  def draw
    accel = mouse_heading - position
    accel.set_mag(0.5)
    @velocity += accel
    if velocity.mag > max_speed
      velocity.set_mag(max_speed)
    end
    @position = position + velocity
    #puts "position is vec2d with x #{position.x}, y #{position.y}, heading #{position.heading}, magnitude #{position.mag}"
    ellipse(@position.x, @position.y, 10, 10)
  end
end
