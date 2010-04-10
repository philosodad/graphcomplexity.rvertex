require 'set'
require 'cover'
class Node
  include VertexCover
  attr_reader :x, :y, :id, :edges, :on, :covers
  attr_accessor :neighbors
  @@id = 0
  def initialize(x,y)
    @on = true
    @x = x
    @y = y
    @neighbors = []
    @edges = Set[]
    @id = @@id
    @@id +=1
    @covers = Set[]
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
  end

  def set_covers
    @covers = build_covers
  end

  def zero_out
    @@id = 0
  end
    
                                 
end
