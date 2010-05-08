require 'ldgraph'
module VCLocal
  attr_reader :matrix
  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    nset = Set.new(@neighbors.collect{|k| k.id})
    @neighbors.each do |k| 
      k.edges.each do |j| 
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    nodes = @neighbors.to_set.add(self)
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

