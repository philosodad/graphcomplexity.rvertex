class Node
  attr_reader :x, :y, :id, :edges, :on
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

  def build_covers
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    @neighbors.each{|k| k.edges.each{|j| alledges.add(j)}}
    
  end
    
                                 
end
