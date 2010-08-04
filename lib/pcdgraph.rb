require 'pcdnode'
require 'set'

class PCD_Graph
  attr_reader :nodes, :edges
  def initialize
    @nodes = []
    @edges = Set[]
  end

  def add_node n
    @nodes.push(n)
    @nodes.uniq!
  end
  
  def set_edges
    n = @nodes.dup
    n.length.times do
      a = n.shift
      n.each{|k| if a.ids - k.ids != a.ids then @edges.add(Set[a.id, k.id]) end}
    end
  end

  def set_degrees
    @nodes.each do |k|
      @edges.each do |j|
        if j.include?(k.id) then k.degree += 1 end
      end
    end
    @nodes.sort!
  end

  def reduce_weight node
    @nodes.each do |k|
      if k.ids.include?(node.id)
        k.reduce_weight(node.weight)
        k.degree += 1
      end
    end
    @nodes.sort!
  end

  def remove_node node
    @nodes.each do |k|
      if k.ids.include?(node.id)
        k.degree = 0
        k.reduce_weight (-1.0/0)
      end
    end
    @nodes.sort!
  end
end
