module Neighborly
  def set_neighbors
    kn = {}
    @nodes.each{|k| kn[k.id] = k}
    @edges.each do |s|
      a = s.to_a
      kn[a[0]].neighbors.push(kn[a[1]])
      kn[a[1]].neighbors.push(kn[a[0]])
    end
  end      

  def set_two_neighborhood
    @nodes.each do |k|
      k.neighbors.each do |j|
        k.neighborhood.push j
      end
      k.neighborhood.uniq!
    end
  end
end

module UnitDiskNeighborly
  def add_nodes(n,deg)
    @nodes.push(SimpleNode.new(rand($space)+$space,rand($space)+$space)) 
    i = 0
    while @nodes.length < n
      (deg-1).ceil.times do 
        x = @nodes[i].x + rand($distance) - rand($distance)
        ydist = get_side((@nodes[i].x - x).abs, $distance)
        y = @nodes[i].y + rand(ydist) - rand(ydist)
        @nodes.push(get_node_type.new(x,y))
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

end

module Connectable
  def make_trees
    trees = []
    tree = []
    nebs = []
    nods = []
    @nodes.each{|k| nods.push(k)}
    until nods.empty?
      i = nods.shift
      tree.push(i)
      i.neighbors.each{|k| nebs.push k}
      x = nebs.length
 #     if x == 0 then puts "#{i.id} has no neighbors and this is the tree: #{tree.class}, #{tree.length}" end
      while !nebs.empty?
        j = nebs.slice!(rand(x))
        tree.push(j)
        nebs = nebs + (j.neighbors - tree)
        x = nebs.length
      end
      trees.push(tree)
      nods = nods - tree
      nods.compact!
      tree = []
    end
#    puts "there are #{trees.length} trees"
    return trees
  end

  def connect?
    make_trees.length > 1
  end
    
  def connect!
    trees = []
    tree = []
    nebs = []
    nods = []
    @nodes.each{|k| nods.push(k)}
    trees = make_trees
    trees.each_index do |i|
      j = i + 1
      if trees[j] != nil
        u = trees[i][rand(trees[i].length)]
        v = trees[j][rand(trees[j].length)]
        u.neighbors.push(v)
        v.neighbors.push(u)
        @edges.add(Set[u.id,v.id])
#        puts "I just added an edge from #{u.id} to #{v.id}"
#        puts @nodes.include?(u)
#        puts @nodes.include?(v)
#        j += 1
      end
    end
  end
end
                     
