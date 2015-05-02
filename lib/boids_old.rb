require "pry"
load_library :vecmath
def setup
  @bounds = Vec2D.new(800, 800)
  size @bounds.x, @bounds.y
  @flock = Flock.new(50, rand(800), rand(800), @bounds)
  fill 255
end

def draw
  background 0
  @flock.birds.each do |b|
    b.steer(@flock.birds)
  end
  @flock.birds.each(&:draw)
end


class Flock
  attr_reader :birds
  def initialize(bird_count, x, y, bounds)
    @birds = Array.new(bird_count) { Bird.new(Vec2D.new(x + rand(-50..50), y + rand(-50..50)), bounds) }
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
  attr_reader :position, :velocity, :bounds, :acceleration

  def initialize(position, bounds)
    @acceleration = Vec2D.new(rand(100), rand(100))
    @acceleration.set_mag(1)
    @position = position
    @bounds = bounds
    @velocity = Vec2D.new
  end

  def neighbor_radius
    60
  end

  def minimum_distance
    20
  end

  def find_heading
  end

  def steer(flockmates)
    #binding.pry
    neighbors = flockmates.reject do |b|
      b.equal?(self)
    end.select do |b|
      b.position.dist(position) < neighbor_radius && b.acceleration.angle_between(acceleration).abs < 3
    end

    if neighbors.any?
      if neighbors.any? { |n| n.position.dist(position) < minimum_distance }
        avg_heading = neighbors.map(&:acceleration).reduce(:+) / neighbors.count
        #TODO - what's the right way to "steer toward" another bird's heading?
        @acceleration = (acceleration - avg_heading) / 2
        #if avg_heading.angle_between(acceleration) > 0
          #@acceleration.rotate(-0.005)
        #else
          #@acceleration = @acceleration.rotate(0.005)
        #end
        #@acceleration = acceleration.rotate(-acceleration.angle_between(avg_heading)/2)
      else
        avg_heading = neighbors.map(&:acceleration).reduce(:+) / neighbors.count
        @acceleration = (avg_heading + acceleration) / 2
        #if avg_heading.angle_between(acceleration) > 0
          #@acceleration.rotate(0.2)
        #else
          #@acceleration = @acceleration.rotate(-0.2)
        #end
        #puts "found neighbors moving toward: #{neighbors.map(&:acceleration)}"
        #puts "averaged their positions to get #{avg_heading}"
        #puts "rotate velocity 1/2 the dist; new pos vec: #{acceleration.copy.rotate(acceleration.angle_between(avg_heading)/2)}"
        #@acceleration = acceleration.rotate(acceleration.angle_between(avg_heading)/2)
      end
    end
  end

  def max_speed
    3
  end

  def wrap_if_out_of_bounds
    if position.x > bounds.x
      position.x = 0
    elsif position.x < 0
      position.x = bounds.x
    end

    if position.y > bounds.y
      position.y = 0
    elsif position.y < 0
      position.y = bounds.y
    end
  end

  def draw
    #accel = mouse_heading - position
    #accel.set_mag(0.5)
    @velocity += @acceleration
    if velocity.mag > max_speed
      velocity.set_mag(max_speed)
    end
    @position = position + velocity
    wrap_if_out_of_bounds
    #puts "position is vec2d with x #{position.x}, y #{position.y}, heading #{position.heading}, magnitude #{position.mag}"
    ellipse(position.x, position.y, 10, 10)
    stroke 255, 60
    stroke_weight 2
    line(position.x, position.y, (position + acceleration).x, (position + acceleration).y)
  end
end
