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
                     
