require "securerandom"
load_library :vecmath
def setup
  # generate a few birds
  size 800, 800
  @flock = Flock.new(10, rand(800), rand(800))
  fill 255
end

def draw
  # each loop
  #  - update bird positions/headings etc
  #  - re-render each bird
  background 0
  #ellipse pos.x, pos.y, 100, 100
  @flock.birds.each do |b|
    b.steer(@flock.birds)
  end
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
  attr_reader :x,:y, :heading, :velocity

  def initialize(x,y,heading)
    #position + Vec2D.new(x,y)
    #position.set_mag(velocity)
    #@position = position
    @velocity = [rand(-5..5), rand(-5..5)]
    @x = x
    @y = y
    @heading = heading
  end

  def neighbor_radius
    30
  end

  def steer(flockmates)
    too_close_neighbors = flockmates.select do |bird|
      (bird.x - x).abs < neighbor_radius && (bird.y - y).abs < neighbor_radius
    end.reject { |b| b.equal?(self) }

    if too_close_neighbors.any?
      puts "too close"
      avg = [too_close_neighbors.map(&:x).reduce(:+)/too_close_neighbors.count,
             too_close_neighbors.map(&:y).reduce(:+)/too_close_neighbors.count]
      if avg[0] > x
        decel_x
      elsif avg[0] < x
        accel_x
      else
        #do nothing
      end

      if avg[1] > y
        decel_y
      elsif avg[1] < y
        accel_y
      else
        #do nothing
      end

      #@velocity = velocity_away_from(avg[0], avg[1])
    else
      puts "go toward mouse"
      @velocity = velocity_toward(mouse_x, mouse_y)
    end
  end

  def accel_x
    @velocity[0] += 1 unless @velocity[0] > max_speed
  end

  def decel_x
    @velocity[0] -= 1 unless @velocity[0] < max_speed
  end

  def accel_y
    @velocity[1] += 1 unless @velocity[1] < max_speed
  end

  def decel_y
    @velocity[1] -= 1 unless @velocity[1] < max_speed
  end

  def max_speed
    5
  end

  def velocity_toward(target_x,target_y)
    v = [0,0]
    if target_x > x
      v[0] = speed
    elsif target_x < x
      v[0] = -speed
    else
      v[0] = 0
    end

    if target_y > y
      v[1] = speed
    elsif target_y < y
      v[1] = -speed
    else
      v[1] = 0
    end
    v
  end

  def velocity_away_from(x,y)
    velocity_toward(x,y).map { |i| -i }
  end

  def draw
    @x = x + velocity[0]
    @y = y + velocity[1]
    #puts "position is vec2d with x #{position.x}, y #{position.y}, heading #{position.heading}, magnitude #{position.mag}"
    ellipse(x, y, 10, 10)
  end
end
