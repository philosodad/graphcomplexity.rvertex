$:.unshift File.join(File.dirname(__FILE__),'..','nodes')
$:.unshift File.join(File.dirname(__FILE__),'..','helpers')
$:.unshift File.join(File.dirname(__FILE__),'..')
#netgen.rb
#Builds networks
require 'node'
require 'planarmath'
require 'set'
require 'node_ldg'
require 'node_match'
require 'node_star'
require 'node_pcd'
require 'node_dumb'
require 'node_fcd'
require 'node_isg'
require 'node_hyper'
require 'target'
require 'helpers_netgen'
                        
class SimpleGraph
  attr_reader :edges, :nodes
  def initialize
    @nodes = []
    @edges = Set[]
  end
  def set_edges
  end
  def set_neighbors
  end

  def add_nodes
  end

  def get_lower_bound
    edgeweights = []
    keyednodes = {}
    @nodes.each{|k| keyednodes[k.id] = k.weight}
    @edges.each do |k|
      w = 0
      k.each{|j| w += keyednodes[j]}
      edgeweights.push(w)
    end
    return edgeweights.min
  end

  def get_on_weight
    weight = 0
    @nodes.each{|k| if k.on == true then weight += k.weight end}
    return weight
  end

  def lowest_weight
    nodes = @nodes.select{|k| k.weight > 0 and k.on}
    return nodes.min_by{|k| k.weight}
  end

  def reduce_by_min
    nodes = @nodes.select{|k| k.weight > 0 and k.on}
    if nodes.empty? then raise StandardError, "reduction for uncovered graph" unless self.covered? end
    min = nodes.min_by{|k| k.weight}.weight
    nodes.each{|k| k.weight = [k.weight - min, 0].max}
    return min
  end

  def get_inverse_weight
    weight = 0
    @nodes.each{|k| if k.on == true then weight += 100-k.weight end}
    return weight
  end

  def get_total_weight
    @nodes.collect{|k| k.weight}.inject(0){|i, j| i+j}
  end

  def get_max_degree
    @nodes.collect{|k| k.neighbors.length}.max
  end

  def get_min_degree
    @nodes.collect{|k| k.neighbors.length}.min
  end

  def get_avg_degree
    (@nodes.collect{|k| k.neighbors.length}.inject(0){|i,j| i+j})/@nodes.length
  end

  def covered?
    onlist = @nodes.collect{|k| k.id if k.on == true and k.weight > 0}
    if @edges.class == Set
      onlist = Set.new(onlist)
    end
    @edges.each{|k| return false if (k & onlist).empty?}
    return true
  end

  def coverable?
    return false if get_lower_bound == 0
    return true
  end

  def isolated?(min)
    @nodes.each{|k| if k.neighbors.length < min then return true end}
    return false
  end

  def reset
    @nodes.each do |k|
      k.on = nil
      k.set_next(:analyze)
      k.set_now(:analyze)
    end
    @nodes.each {|k| k.set_ons}
    @nodes.each do |k|
      if k.weight == 0 then 
        k.on = false
        k.set_next(:out_of_batt)
      end
    end
  end
  
  def remove_node n
    @edges.delete_if{|k| k.include?(n.id)}
    @nodes.delete_if{|k| k.id == n.id}
    n.remove_self
  end
    
end
    
class MatchGraph < SimpleGraph
  include Neighborly
  include Connectable
  def initialize g
    super()
    n = []
    ntype = get_node_type
    g.nodes.each{|k| n.push(ntype.new(k))}
    @nodes = n
    g.edges.each{|k| @edges.add(k)}
    set_neighbors
  end

  def get_node_type
    Object.const_get('MatchNode')
  end

  def reset
    @nodes.each{|k| k.reset}
  end

  def invert_weight
  end
end
                           
class MatchMaxGraph < MatchGraph
  def initialize g
    super(g)
    n = []
    g.nodes.each{|k| n.push(MatchMaxNode.new(k))}
    @nodes = n
    g.edges.each{|k| @edges.add(k)}
    set_neighbors
  end
end

class MatchRedGraph < MatchGraph
  def initialize g
    super(g)
    n = []
    g.nodes.each{|k| n.push(MatchRedNode.new(k))}
    @nodes = n
    set_neighbors
  end
end
                          

class MatchMWMGraph < MatchGraph
  def initialize g
    super(g)
    n = []
    g.nodes.each{|k| n.push(MatchMWMNode.new(k))}
    @nodes = n
    set_neighbors
  end
end

class RandomGraph < SimpleGraph
  include Neighborly
  include Connectable
  def initialize(n, e)
    @nodes = []
    @edges = Set[]
    add_nodes n
    set_edges(n,e)
    set_neighbors
    connect!
  end
  
  def add_nodes n
    n.times{@nodes.push(LDGNode.new(0,0))}
  end

  def set_edges(n,e)
    m = @nodes.collect{|k| k.id}
    until @edges.length == e
      x = rand(n)
      y = x
      until y != x
        y = rand(n)
      end
      i = m[x]
      j = m[y]
      s = Set[i,j]
      @edges.add(s)
    end
  end
end

class RandomGraphRed < RandomGraph
  def initialize(*args)
    if args.length == 1 and args[0].class == RandomGraph
      g = args[0]
      @edges = g.edges
      @nodes = []
      put_nodes(g)
      set_neighbors
    else
      super(args[0], args[1])
    end
  end
  
  def add_nodes n
    n.times{@nodes.push(LDGRedNode.new(0,0))}
  end

  def put_nodes g
    g.nodes.each{|k| @nodes.push(LDGRedNode.new(k))}
  end

end

class RandomGraphShort < RandomGraphRed
  def add_nodes n
    n.times{@nodes.push(LDGShortRedNode.new(0,0))}
  end

  def put_nodes(g)
    g.nodes.each{|k| @nodes.push(LDGShortRedNode.new(k))}
  end
end

class UnitDiskGraph < SimpleGraph
  include PlanarMath
  include Connectable
  def initialize(size, space, distance)
    @nodes = []
    @edges = Set[]
    size.times{@nodes.push(SimpleNode.new(rand(space), rand(space)))}
    set_neighbors distance
    set_edges
  end
        
  def set_edges
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end
  
  def set_neighbors d
    def add_by dim, d
      nods = @nodes.sort_by{|k| k.send(dim)}
      dict = {}
      @nodes.each{|k| dict[k] = []}
      nods.each_index do |k|
        up = k+1
        while up < @nodes.length and ((nods[k].send dim.to_sym) - (nods[up].send dim.to_sym)).abs <= d
          dict[nods[k]].push(nods[up])
          dict[nods[up]].push(nods[k])
          up += 1
        end
      end
      return dict
    end
    exis = add_by('x', d)
    whys = add_by('y', d)
    @nodes.each do |k|
      nebs = (exis[k])&(whys[k])
      k.neighbors = nebs.select{|j| planar_distance(j,k) <= d}
    end
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

  def set_edges
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end

  def isolated?(min)
    @nodes.each{|k| if k.neighbors.length < min then return true end}
    return false
  end

end

class GridGraph < SimpleGraph
  include PlanarMath
  def initialize size, min
    super()
    add_nodes size
    @byx = @nodes.sort_by{|k| k.x}
    @byy = @nodes.sort_by{|k| k.y}
    set_neighbors min, 8
    set_edges
  end

  def add_nodes size
    (0...size).each do |x| 
      (0...size-1).each do |y| 
        if y%2 == 0 and x < size-1 then
          @nodes.push(LDGNode.new((x*6)+3,(y*4)))
        elsif y%2 == 1 then
          @nodes.push(LDGNode.new((x*6), (y*4)))
        end
      end
    end
  end
  
  def set_neighbors min, distance
    choices = {}
    ids = {}
    @nodes.each do |k|
      choices[k.id] = []
      xpossibles = []
      ypossibles = []
      xindex = @byx.index(k)
      yindex = @byy.index(k)
      up = 1
      down = -1
      until @byx[xindex+up] == nil or (@byx[xindex+up].x - k.x).abs > distance do
        xpossibles.push(@byx[xindex+up])
        up +=1
      end
      until xindex+down < 0 or (@byx[xindex+down].x - k.x).abs > distance do
        xpossibles.push(@byx[xindex+down])
        down -= 1
      end
      up = 1
      down = -1
      until @byy[yindex+up] == nil or (@byy[yindex+up].y - k.y).abs > distance do
        ypossibles.push(@byy[yindex+up])
        up +=1
      end
      until yindex+down < 0 or (@byy[yindex+down].x - k.y).abs > distance do
        ypossibles.push(@byy[yindex+down])
        down -= 1
      end
      possibles = ypossibles + xpossibles
      choices[k.id].concat(possibles.select{|i| planar_distance(k,i) < distance}) 
    end

    while isolated?(min)
      now = @nodes[rand(@nodes.length)]
      while now != nil
        maybes = choices[now.id]
        if maybes.length > 0 then
          soon = maybes[rand(maybes.length)]
          now.neighbors.concat([soon])
          soon.neighbors.concat([now])
          choices[now.id] = choices[now.id] - [soon]
          choices[soon.id] = choices[soon.id] - [now]
          now = soon
        else
          now = nil
        end
      end
    end
  end
        
  def set_edges
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end

  def isolated?(min)
    @nodes.each{|k| if k.neighbors.length < min then return true end}
    return false
  end
end

class TotalWeightGraph < GridGraph
  def add_node size
    (0...size+1).each do |x| 
      (0...size).each do |y| 
        if y%2 == 0 and x%2 == 0 then
          @nodes.push(TotalWeightNode.new((x*3)+3,(y*4)))
        elsif x%2 == 1 and y%2 == 1 then
          @nodes.push(TotalWeightNode.new(((x*3)-3), (y*4)))
        end
      end
    end
  end
end

class DegreeWeightGraph < GridGraph
  def add_node size
    (0...size+1).each do |x|
      (0...size).each do |y|
        if y%2 == 0 and x%2 == 0 then
          @nodes.push(DegreeWeightNode.new((x*3)+3,(y*4)))
        elsif x%2 == 1 and y%2 == 1 then
          @nodes.push(DegreeWeightNode.new((x*3)+3, (y*4)))
        end
      end
    end
  end
end

class CoverGridGraph < GridGraph
  def add_node size
    (0..size).each do |x|
      (0...size).each do |y|
        if y%2 == 0 and x%2 == 0 then
          @nodes.push(CoverNode.new((x*3)+3,(y*4)))
        elsif x%2 == 1 and y%2 == 1 then
          @nodes.push(CoverNode.new(((x*3)-3), (y*4)))
        end
      end
    end
  end
end

class CoverNodeGraph < SimpleGraph
  include Neighborly
  def initialize g
    super()
    n = []
    g.nodes.each{|k| n.push(CoverNode.new(k))}
    @nodes = n
    g.edges.each{|k| @edges.add(k)}
    set_neighbors
  end
end

class SetObsNodeGraph < SetGraph
  def initialize g
    @nodes = []
    @edges = g.edges
    g.nodes.each{|k| @nodes.push(SetNodeObs.new(k))}
    @nodes.each do |k|
      @edges.each do |j|
        if j.include?(k.id)
          k.neighbors.concat(@nodes.select{|i| (j - Set[k.id]).include?(i.id)})
        end
      end
    end
  end
end
