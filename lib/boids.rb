def setup
  size 800, 600
  puts "calling setup on start"
  # create some birds
  @flock = (1..10).map { Bird.new(rand(800), rand(600))}
end


def draw
  background(255, 255, 255)
  # address/update steering of each bird
  # move each bird by its speed in the direction that it's heading
  # draw each bird

  #@flock.each { |b| puts "#{b} has #{b.neighbors(@flock).count} neighbors"}
  @flock.each { |b| b.adjust_course(@flock) }
  @flock.each { |b| b.move! }
  @flock.each { |b| b.wrap!(width, height) }
  @flock.each { |b| b.draw }
end

class Bird
  attr_reader :x, :y, :speed, :heading
  def initialize(x,y)
    @x = x
    @y = y
    @speed = 3
    @heading = rand * TWO_PI
  end

  def x_offset
    speed * cos(heading)
  end

  def y_offset
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

  def neighbors(flock, radius = 60)
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
      avoid = crowders.min_by { |c| dist(x, y, c.x, c.y) }
      puts "bird heading at #{heading} will steer to avoid #{avoid.heading}"
      steer_from(avoid.heading)
    end
    ensure_valid_heading!
  end

  def ensure_valid_heading!
    @heading = @heading % TWO_PI
  end

  def steer_from(heading)
    if self.heading < heading
      @heading += QUARTER_PI
    else
      @heading -= QUARTER_PI
    end
  end
  # give a bird an angle / heading
  # tell it to "steer away from" that heading
  # have it adjust its own heading
  # if your heading is smaller than other bird's heading
  #     -> add some angle
  # else
  #     -> sub some angle ?

  def draw
    ellipse(x, y, 20, 20)
  end
end
