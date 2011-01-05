require 'set'
class WeightedEdge
  attr_reader :uv
  attr_accessor :weight
  def initialize e
    @uv = e
    @weight = nil
  end
end

class ColoredEdge
  attr_reader :uv
  attr_accessor :color
  def initialize e
    @uv = e
    @color = nil
  end
end
    
