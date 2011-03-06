module Neighborly
  def set_neighbors
    kn = {}
    @nodes.each{|k| kn[k.id] = k}
    @edges.each do |s|
      a = s.to_a.dup
      (a.length - 1).times do 
        b = a.shift
        a.each do |k|
          kn[b].neighbors.push(kn[k])
          kn[k].neighbors.push(kn[b])
          [kn[b].neighbors, kn[k].neighbors].each do |j|
            j.uniq!
            j.compact!
          end
        end
      end
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

  def set_neighbors
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

module Targetable
  def add_from_to_by from, into, by
    nto = into.sort_by{|k| k.send(by)}
    fronto = (from + nto).sort_by{|k| k.send(by)}
    dict = {}
    nto.each{|k| dict[k] = []}
    nto.each do |k|
      pin = fronto.index(k)
      up = pin+1
      down = pin-1
      while up < fronto.length and ((fronto[pin].send(by)) - (fronto[up].send(by))).abs <= $sensor_range
        if fronto[up].kind_of?(BasicNode) then dict[k].push(fronto[up]) end
        up += 1
      end
      while down >= 0 and ((fronto[pin].send(by)) - (fronto[down].send(by))).abs <= $sensor_range
        if fronto[down].kind_of?(BasicNode)
          dict[k].push(fronto[down])
        end
        down -= 1
      end
    end
    return dict
  end 

  def build_connectable_graph n, t
    targets = add_connectable_targets t
    nodes = targets.collect do |k|
      x,y = coord_within_distance(k, $sensor_range)
      Target.new(x,y)
    end
    until nodes.length == n
      x, y = coord_within_distance(targets.sample, $sensor_range)
      nodes.push(Target.new(x,y))
    end
    return nodes, targets
  end

  def add_connectable_targets t
    a = [Target.new(rand($space),rand($space))]
    until a.length == t
      x, y = coord_within_distance(a.sample, $distance)
      a.push(Target.new(x,y))
    end
    a
  end

  def add_connected_targets n, t
    a = []
    t.times do |k|
      x,y = coord_within_distance(n.sample, $sensor_range)
      a.push(Target.new(x,y))
    end
    a
  end

  def add_targets t
    targets = []
    t.times do
      targets.push(Target.new(rand($space), rand($space)))
    end
    return targets
  end

  def add_randomly nodes, t
    a = []
    t.times{a.push([])}
    nodes.each{|k| a[rand(t)].push(k.id)}
    a.select{|k| k.any?}
  end
end


                     
