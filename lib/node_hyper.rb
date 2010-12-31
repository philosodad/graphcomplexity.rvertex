require 'node'

class HyperNode < BasicNode
  attr_reader :x, :y
  def initialize x, y
    super()
    @x = x
    @y = y
  end
end
