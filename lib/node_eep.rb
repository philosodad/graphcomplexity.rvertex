require 'node'
require 'actions_eep'
require 'edge_eep'

class DeepRootNode < BasicNode
  include Comparable
  attr_reader :poorest
  def initialize
    super()
    @poorest
    @charges = []
  end
  
  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
    e = @edges.to_a
    @edges = Set[]
    e.each{|k| @edges.add(DeepsEdge.new(k))}
  end

  def test_hills
    e = @edges - [@poorest]
    p = @neighbors.collect{|k| k.poorest}
    e = e - p
    e.each do |k|
      n = @neighbors.select{|j| k.include?(j.id)}[0]
      if self.poorest > n.poorest
        @charges.push(k)
      elsif self.poorest == n.poorest
        if self > n
          @charges.push(k)
        end
      end
    end
  end
    
  end
    
  def find_poorest_edge
    n = @neighbors.min
    @poorest = @edges.select{|k| k.uv.include?(n.id)}[0]
    if self == n.neighbors.min_by{|k| k.weight} then
      if self >= n 
        @charges.push(@poorest)
      end
    else
      @charges.push(@poorest)
    end
  end

  def <=> other
    if @weight < other.weight
      return -1
    elsif @weight > other.weight
      return 1
    elsif @id < other.id
      return -1
    else
      return 1
    end
  end

end

class DeepRedNode < DeepRootNode
end
