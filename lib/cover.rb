require 'ldgraph'
require 'pcdgraph'

module PCD
  attr_reader :first_cover
  def build_first_cover
    if @neighbors.empty? then return :empty end
    nset = Set.new(@neighbors)
    nnset = Set.new(@neighbors.collect{|k| k.neighbors}.flatten)-nset
    a = PCD_Graph_Node.new(nset.to_a)
    b = PCD_Graph_Node.new(nnset.to_a)
    @first_cover = [a,b].min
    @covers.add_node(@first_cover)
  end
  def get_covers
    @neighbors.each{|k|  @covers.add_node(k.first_cover.dup)}
  end
end

module VCLocal
  attr_reader :matrix
  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    nset = Set.new(@neighbors.collect{|k| k.id})
    nset.add(@id)
    @neighbors.each do |k| 
      k.edges.each do |j| 
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    nodes = @neighbors.to_set.add(self)
    nodes = nodes.to_a
    @n = nodes.collect{|k| k.id}
    alledges = alledges.to_a    
    def build_all_subsets
      n = @n
      subsets = [n]
      m = n - [@id]
      x = m.length
      subsets.push(m)
      (1..x).each do |k|
        subsets = subsets+(m.combination(k).to_a)
      end
      subsets.each_index{|k| if k>1 then subsets[k].push(@id) end}
      subsets.push([@id])
      subsets.each_index{|k| subsets[k] = subsets[k].to_set}
      subsets.to_set
      return subsets
    end

    def test_cover(edges, cover)
      edges.each{|k| return false if cover-k == cover} 
    end
    @c = build_all_subsets.select{|k| test_cover(alledges, k)}.to_set
    return LdGraph.new(@c, nodes)
  end  
end

module VCLocalShort
  attr_reader :matrix
  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    nset = Set.new(@neighbors.collect{|k| k.id})
    nset.add(@id)
    @neighbors.each do |k| 
      k.edges.each do |j| 
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    nodes = @neighbors.to_set.add(self)
    nodes = nodes.to_a
    @n = nodes.collect{|k| k.id}
    alledges = alledges.to_a    
    def build_all_subsets
      n = @n
      subsets = [n]
      m = n - [@id]
      x = m.length
      subsets.push(m)
      (1..x).each do |k|
        subsets = subsets+(m.combination(k).to_a)
      end
      subsets.each_index{|k| if k>1 then subsets[k].push(@id) end}
      subsets.push([@id])
      subsets.each_index{|k| subsets[k] = subsets[k].to_set}
      subsets.to_set
      return subsets
    end

    def test_cover(edges, cover)
      edges.each{|k| return false if cover-k == cover} 
    end
    @c = build_all_subsets.select{|k| test_cover(alledges, k)}.to_set
    return ShortLifeLdGraph.new(@c, nodes)
  end  
end

module VCLocal_Obs
  attr_reader :matrix
  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    nset = Set.new(@neighbors.collect{|k| k.id})
    nset.add(@id)
    @neighbors.each do |k| 
      k.edges.each do |j| 
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    nodes = @neighbors.to_set.add(self)
    nodes = nodes.to_a
    @n = nodes.collect{|k| k.id}
    alledges = alledges.to_a    
    def build_all_subsets
      n = @n
      subsets = [n]
      m = n - [@id]
      x = m.length
      subsets.push(m)
      while x > 1
        thesesets = subsets.select{|k| k.length == x}
        thesesets.each do |k|
          k.each_index do |j|
            r = k.dup
            r.slice!(j)
            subsets.push(r)
          end
        end
        subsets.uniq!
        x -=1
      end
      subsets.each_index{|k| if k>1 then subsets[k].push(@id) end}
      subsets.push([@id])
      subsets.each_index{|k| subsets[k] = subsets[k].to_set}
      subsets.to_set
      return subsets
    end
    
    def test_cover(edges, cover)
      edges.each{|k| return false if cover-k == cover} 
    end
    @c = build_all_subsets.select{|k| test_cover(alledges, k)}.to_set
    return LdGraph.new(@c, nodes)
  end  
end

module TotalWeightVC
  attr_reader :matrix
  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    nset = Set.new(@neighbors.collect{|k| k.id})
    nset.add(@id)
    @neighbors.each do |k| 
      k.edges.each do |j| 
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    nodes = @neighbors.to_set.add(self)
    nodes = nodes.to_a
    @n = nodes.collect{|k| k.id}
    alledges = alledges.to_a    
    def build_all_subsets
      n = @n
      subsets = [n]
      m = n - [@id]
      x = m.length
      subsets.push(m)
      while x > 1
        thesesets = subsets.select{|k| k.length == x}
        thesesets.each do |k|
          k.each_index do |j|
            r = k.dup
            r.slice!(j)
            subsets.push(r)
          end
        end
        subsets.uniq!
        x -=1
      end
      subsets.each_index{|k| if k>1 then subsets[k].push(@id) end}
      subsets.push([@id])
      subsets.each_index{|k| subsets[k] = subsets[k].to_set}
      subsets.to_set
      return subsets
    end

    def test_cover(edges, cover)
      edges.each{|k| return false if cover-k == cover} 
    end
    @c = build_all_subsets.select{|k| test_cover(alledges, k)}.to_set
    return TotalWeightLdGraph.new(@c, nodes)
  end  
end

module DegreeWeightVC
  attr_reader :matrix
  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    nset = Set.new(@neighbors.collect{|k| k.id})
    nset.add(@id)
    @neighbors.each do |k| 
      k.edges.each do |j| 
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    nodes = @neighbors.to_set.add(self)
    nodes = nodes.to_a
    @n = nodes.collect{|k| k.id}
    alledges = alledges.to_a    
    def build_all_subsets
      n = @n
      subsets = [n]
      m = n - [@id]
      x = m.length
      subsets.push(m)
      while x > 1
        thesesets = subsets.select{|k| k.length == x}
        thesesets.each do |k|
          k.each_index do |j|
            r = k.dup
            r.slice!(j)
            subsets.push(r)
          end
        end
        subsets.uniq!
        x -=1
      end
      subsets.each_index{|k| if k>1 then subsets[k].push(@id) end}
      subsets.push([@id])
      subsets.each_index{|k| subsets[k] = subsets[k].to_set}
      subsets.to_set
      return subsets
    end

    def test_cover(edges, cover)
      edges.each{|k| return false if cover-k == cover} 
    end
    @c = build_all_subsets.select{|k| test_cover(alledges, k)}.to_set
    return DegreeWeightLdGraph.new(@c, nodes)
  end  
end


module VertexCover
  attr_reader :matrix
  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    @neighbors.each{|k| k.edges.each{|j| alledges.add(j)}}
    nodes = @neighbors.to_set.add(self)
    @neighbors.each{|k| k.neighbors.each{|j| nodes.add(j)}}
    nodes = nodes.to_a
    nodes = nodes.sort_by{|k| k.id}
    alledges = alledges.to_a
    @matrix = []
    alledges.each{@matrix.push([])}
    alledges.each_index do |k|
      nodes.each do |j|
        if alledges[k].include?(j.id) then
          @matrix[k].push(1)
        else
          @matrix[k].push(0)
        end
      end
    end
    
    def rec_build_covers(x,y,c,covers, nodes) 
      cover = c.dup
      if x == @matrix.length
        covers.add(cover)
#        puts "adding a cover"
        return covers
      elsif y == @matrix[x].length
#        puts "no more nodes to add in this row"
        return covers
      elsif @matrix[x][y] == 0
        rec_build_covers(x, y+1, cover, covers, nodes)
      elsif @matrix[x][y] == 1
        cover.add(nodes[y].id)
#        puts "increase x"
        rec_build_covers(x+1, 0, cover, covers, nodes)
#        puts "now increase y"
        rec_build_covers(x, y+1, c, covers, nodes)
      end
    end
    return LdGraph.new(rec_build_covers(0,0, Set[], Set[], nodes), nodes)
  end  
end

module SimpleVC
  def build_covers
    covers = Set[]
    covers.add(Set[@id])
    covers.add(Set.new(@neighbors.collect{|k| k.id}))
    return SimpleLdGraph.new(covers, @neighbors + [self])
  end
end


module CoverComposer
  def build_matrix nodes, edges
  end

  def decompose_matrix matrix
  end

  def compose_from matrix
    covers = []
    stop = false
    x = 0
    y = 0
    memo = []
    matrix.length.times{|k| memo[k] = 0}
    until stop
      puts "x:#{x},y:#{y}"
      if x < matrix.length and y < matrix[x].length
        if matrix[x][y] == 0
          y += 1
        elsif matrix[x][y] == 1
          memo[x] = y
          x+=1
          y = 0
        end
      elsif x == matrix.length
        puts "found a cover: #{memo}"
        covers.push(memo.dup)
        x -= 1
        y = memo[x] + 1
      elsif y == matrix[x].length
        if x > 0
          memo[x] = 0
          x -= 1
          y = memo[x] + 1
        else
          stop = true
        end
      end
    end
    return covers
  end
end
