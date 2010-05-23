#netgen.rb
#Builds networks
require 'node'
require 'planarmath'
require 'set'

class SimpleGraph
  attr_reader :edges, :nodes
  def initialize
    @nodes = []
    @edges = Set[]
  end
  def setEdges
  end
  def setNeighbors
  end

  def getOnWeight
    weight = 0
    @nodes.each{|k| if k.on == true then weight += k.weight end}
    return weight
  end

  def getInverseWeight
    weight = 0
    @nodes.each{|k| if k.on == true then weight += 100-k.weight end}
    return weight
  end

  def get_total_weight
    @nodes.collect{|k| k.weight}.inject(0){|i, j| i+j}
  end

  def covered?
    onlist = Set.new(@nodes.collect{|k| k.id if k.on == true})
    @edges.each{|k| return false if k-onlist == k}
    return true
  end

  def remove_node n
    @edges.delete_if{|k| k.include?(n.id)}
    @nodes.delete_if{|k| k.id = n.id}
    n.remove_self
  end
    
end


class MatchGraph < SimpleGraph
  def initialize g
    super()
    @n = []
    g.nodes.each{|k| @n.push(MatchNode.new(k))}
    @nodes = @n
    g.edges.each{|k| @edges.add(k)}
    setNeighbors
  end

  def setNeighbors
    kn = {}
    @nodes.each{|k| kn[k.id] = k}
    @edges.each do |s|
      a = s.to_a
      kn[a[0]].neighbors.push(kn[a[1]])
      kn[a[1]].neighbors.push(kn[a[0]])
    end
  end

      
end
                           
class MatchMaxGraph < MatchGraph
  def initialize g
    super(g)
    @n = []
    g.nodes.each{|k| @n.push(MatchMaxNode.new(k))}
    @nodes = @n
  end
end

class RandomGraph < SimpleGraph
  def initialize(n, e)
    @nodes = []
    @edges = Set[]
    n.times{@nodes.push(Node.new(0,0))}
    setEdges(n,e)
    setNeighbors
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
  end

  def setNeighbors
    kn = {}
    @nodes.each{|k| kn[k.id] = k}
    @edges.each do |s|
      a = s.to_a
      kn[a[0]].neighbors.push(kn[a[1]])
      kn[a[1]].neighbors.push(kn[a[0]])
    end
  end
end

class UnitDiskGraph < SimpleGraph
  include PlanarMath
  def initialize(size, space, distance)
    @nodes = []
    @edges = Set[]
    size.times{@nodes.push(Node.new(rand(space), rand(space)))}
    @nodes.each{|k| setNeighbors(k, distance)}
    setEdges
  end

  def setEdges
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end
  
  def setNeighbors(node, distance)
    possibles = @nodes - [node]
    possibles = possibles.select{|k| (k.x - node.x).abs <= distance}
    possibles = possibles.select{|k| (k.y - node.y).abs <= distance}
    node.neighbors.concat(possibles.select{|k| planardist(k, node) <= distance})
  end
end

class SetGraph < SimpleGraph
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

class GridGraph < SimpleGraph
  include PlanarMath
  def initialize size, min
    super()
    if size%2 == 0 then size -= 1 end
    (0...size+1).each do |x| 
      (0...size).each do |y| 
        if y%2 == 0 and x%2 == 0 then
          @nodes.push(Node.new((x*3)+3,(y*4)))
        elsif x%2 == 1 and y%2 == 1 then
          @nodes.push(Node.new(((x*3)-3), (y*4)))
        end
      end
    end
    @nodes = @nodes.select{|k| k.x < size*3 and k.y < size*3}
    now = false
    while isolated?(min) do
      if not now
        opennodes = @nodes.select{|k| k.neighbors.length < 6}
        now = opennodes[rand(opennodes.length)]
      end
      choices = @nodes.select{|i| planardist(i,now) < 8} - ([now] + now.neighbors)
      updated = false
      while choices.length > 0
        soon = choices[rand(choices.length)]
        if now.neighbors.include?(soon)
          choices.slice!(choices.index(soon))
        else not now.neighbors.include?(soon)
          now.neighbors.push(@nodes[@nodes.index(soon)])
          soon.neighbors.push(@nodes[@nodes.index(now)])
          now = @nodes[@nodes.index(soon)]
          choices = []
          updated = true
        end
      end
      now = false unless updated == true
    end
    setEdges
  end

  def setEdges
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end

  def isolated?(min)
    @nodes.each{|k| if k.neighbors.length < min then return true end}
    return false
  end
end
