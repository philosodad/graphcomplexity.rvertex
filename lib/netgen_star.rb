require 'netgen'

class StarGraph < SimpleGraph
  include Neighborly
  def initialize g
    super()
    @edges = g.edges
    @nodes = []
    put_nodes g
    set_neighbors
  end

  def put_nodes g
    g.nodes.each{|k| @nodes.push(StarNode.new(k))}
  end
end

class StarRedGraph < StarGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(StarRedNode.new(k))}
  end
end
    
