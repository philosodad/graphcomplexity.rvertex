require 'set'
class WeightedEdge
  attr_reader :uv
  attr_accessor :weight
  def initialize e
    @uv = e
    @weight = nil
  end
end
    
