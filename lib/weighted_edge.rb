require 'set'
class WeightedEdge
  attr_reader :uv, :criteria
  attr_accessor :weight
  alias :criteria :weight
  def initialize e
    @uv = e
    @weight = nil
  end
end

class ColoredEdge
  attr_reader :uv, :criteria
  attr_accessor :color
  alias :criteria :color
  def initialize e
    @uv = e
    @color = nil
  end
end
    
class DirectedColorEdge < ColoredEdge
  def initialize e
    @uv = e
    @color = {:in => nil, :out => nil}
  end

  def + other
    self.to_i + other.to_i
  end

  def coerce(other)
    return Integer(self), other
  end

  def to_i
    @color.values.select{|k| k == nil}.length
  end
end 
