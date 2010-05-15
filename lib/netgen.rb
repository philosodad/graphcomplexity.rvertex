#netgen.rb
#Builds networks
require 'node'
require 'planarmath'
require 'set'

class RandomGraph
  attr_reader :edges, :nodes
  def initialize(n, e)
    @nodes = []
    @edges = Set[]
    n.times{@nodes.push(Node.new(0,0))}
    setEdges(n,e)
    setneighbors
  end
  
  def setEdges(n,e)
    m = @nodes.collect{|k| k.id}
    a = []
    x = m.length
    while x > 1
      l = m.slice!(0)
      m.each{|k| a.push(Set[l,k])}
      x = m.length
    end
    x = a.length
    e.times do 
        @edges.add(a.slice!(rand(x-1)))
        x = a.length
    end
        
=begin    until @edges.length == e do
      n1 = @nodes[rand(n-1)]
      n2 = @nodes[rand(n-1)]
      @edges.add(Set[n1.id, n2.id]) unless n1 == n2
=end    end
  end

  def setneighbors
    kn = {}
    @nodes.each{|k| kn[k.id] = k}
    @edges.each do |s|
      a = s.to_a
      kn[a[0]].neighbors.push(kn[a[1]])
      kn[a[1]].neighbors.push(kn[a[0]])
    end
  end
                              

end

class UnitDiskGraph
  include PlanarMath
  attr_reader :edges, :nodes
  def initialize(size, space, distance)
    @nodes = []
    @edges = Set[]
    size.times{@nodes.push(Node.new(rand(space), rand(space)))}
    @nodes.each{|k| setneighbors(k, distance)}
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end

  def setneighbors(node, distance)
    possibles = @nodes - [node]
    possibles = possibles.select{|k| (k.x - node.x).abs <= distance}
    possibles = possibles.select{|k| (k.y - node.y).abs <= distance}
    node.neighbors.concat(possibles.select{|k| planardist(k, node) <= distance})
  end
end

class SetGraph
  attr_reader :edges, :nodes
  def initialize nodes, edges
    @nodes = nodes
    @edges = edges
    @nodes.each do |k|
      @edges.each do |j|
        if j.include?(k.id)
          k.neighbors.concat(@nodes.select{|i| (j - Set[k.id]).include?(i.id)})
        end
      end
    end
  end

    
end
