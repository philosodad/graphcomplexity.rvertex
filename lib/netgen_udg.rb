require 'netgen'

class UDG_Graph < SimpleGraph
  include PlanarMath
  include Connectable
  def initialize(n,deg)
    super()
    add_nodes(n,deg)
    set_neighbors
    set_edges
  end

  def add_nodes(n,deg)
    @nodes.push(SimpleNode.new(rand($space)+$space,rand($space)+$space)) 
    i = 0
    while @nodes.length < n
      (deg-1).ceil.times do 
        x = @nodes[i].x + rand($distance) - rand($distance)
        ydist = get_side((@nodes[i].x - x).abs, $distance)
        y = @nodes[i].y + rand(ydist) - rand(ydist)
        @nodes.push(SimpleNode.new(x,y))
      end
      i += 1
    end
    @nodes = @nodes.slice(0,n)
    puts "nodes built!"
  end

  def set_neighbors
    def add_by dim
      nods = @nodes.sort_by{|k| k.send(dim)}
      dict = {}
      @nodes.each{|k| dict[k] = []}
      nods.each_index do |k|
        up = k+1
        while up < @nodes.length and ((nods[k].send dim.to_sym) - (nods[up].send dim.to_sym)).abs <= $distance
          dict[nods[k]].push(nods[up])
          dict[nods[up]].push(nods[k])
          up += 1
        end
      end
      return dict
    end
    exis = add_by('x')
    whys = add_by('y')
    @nodes.each do |k|
      nebs = (exis[k])&(whys[k])
      k.neighbors = nebs.select{|j| planar_distance(j,k) <= $distance}
    end
    puts "neighbors added!"
  end

  def set_edges
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end
end
