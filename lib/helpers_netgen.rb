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
  def connect!
    trees = []
    tree = []
    nebs = []
    nods = []
    @nodes.each{|k| nods.push(k)}
    while !nods.empty?
      i = nods[0]
      tree.push(i)
      nebs = i.neighbors
      x = nebs.length
#      if x == 0 then puts "#{i.id} has no neighbors and this is the tree: #{tree.class}, #{tree.length}" end
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
                     
