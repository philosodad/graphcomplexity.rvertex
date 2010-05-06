require 'set'
require 'cover'
require 'ldgraph'
class Node
  include VertexCover
  attr_reader :x, :y, :id, :edges, :covers
  attr_accessor :neighbors, :weight, :on
  @@id = 0
  def initialize(x,y)
    @on = true
    @x = x
    @y = y
    @id
    @neighbors = []
    @edges = Set[]
    updateid
    @covers = Set[]
    @weight = rand(50)+50
  end

  def updateid
    @id = @@id
    @@id += 1
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

class SetNode < Node
  def initialize(id)
    super(0,0)
    @id = id
  end

  def updateid
  end
end
