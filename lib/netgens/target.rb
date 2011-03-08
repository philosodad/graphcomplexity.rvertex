class Target
  include Comparable
  @@id = 0
  attr_reader :x, :y, :id
  attr_accessor :cover
  def initialize(x,y)
    @x = x
    @y = y
    @id = @@id
    @@id += 1
    @cover = []
  end

  def zero_out
    @@id = 0
  end
end
