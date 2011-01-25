class Target
  @@id = 0
  attr_reader :x, :y, :id
  def initialize(x,y)
    @x = x
    @y = y
    @id = @@id
    @@id += 1
  end

  def zero_out
    @@id = 0
  end
end
