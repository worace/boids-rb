def setup
  size 1000, 800
  puts "calling setup on start"
  # create some birds
  @flock = (1..50).map { Bird.new(rand(800), rand(600))}
end

#def key_pressed
  #sleep(5)
#end

def draw
  background(137,223,240)
  # address/update steering of each bird
  # move each bird by its speed in the direction that it's heading
  # draw each bird

  #@flock.each { |b| puts "#{b} has #{b.neighbors(@flock).count} neighbors"}
  @flock.each { |b| b.adjust_course(@flock) }
  @flock.each { |b| b.move! }
  @flock.each { |b| b.wrap!(width, height) }
  @flock.each { |b| b.jitter }
  @flock.each { |b| b.draw }
end

class Bird
  attr_reader :x, :y, :speed
  attr_accessor :heading
  def initialize(x,y)
    @x = x
    @y = y
    @speed = 10
    @heading = rand * TWO_PI
  end

  def jitter
    if rand(2) % 2 == 0
      self.heading += rand * 0.1
    else
      self.heading -= rand * 0.1
    end
  end

  def x_offset(speed = speed)
    speed * cos(heading)
  end

  def y_offset(speed = speed)
    speed * sin(heading)
  end

  def move!
    @x = x + x_offset
    @y = y + y_offset
  end

  def wrap!(width, height)
    @x = x % width
    @y = y % height
  end

  def neighbors(flock, radius = 140)
    flock.select do |b|
      d = dist(x, y, b.x, b.y)
      d < radius && d > 0
    end
  end

  def crowders(neighbors)
    self.neighbors(neighbors, 50)
  end

  def adjust_course(flock)
    crowders = crowders(flock)
    if crowders.any?
      avoid(crowders)
    else
      local_neighbors = self.neighbors(flock, 140)
      cohere(local_neighbors)
    end
    ensure_valid_heading!
  end

  def ensure_valid_heading!
    @heading = @heading % TWO_PI
  end

  def avoid(other_birds)
    avoid = other_birds.min_by { |c| dist(x, y, c.x, c.y) }
    if self.heading < avoid.heading
      @heading = heading
      @heading -= 0.02
    #else
      #@heading += 0.1
    end
  end


  def cohere(other_birds)
    if other_birds.any?
      group_avg = (other_birds.map(&:heading).reduce(:+) / other_birds.count)
      diff = (group_avg - self.heading) 
      self.heading += (diff/8)
    end
  end

  def draw
    fill 0, 0, 50
    stroke 0, 0, 75
    stroke_width 1
    offset_a = 20
    offset_b = 15
    triangle(x + offset_a*Math.cos(heading), y + offset_a*Math.sin(heading),
             x + offset_b*Math.cos(heading-(5*PI/6)), y + offset_b*Math.sin(heading-(5*PI/6)),
             x + offset_b*Math.cos(heading+(5*PI/6)), y + offset_b*Math.sin(heading+(5*PI/6)))
    #fill 0, 0, 0, 0
    #ellipse(x,y,140, 140)
    #ellipse(x,y,80, 80)
  end
end
