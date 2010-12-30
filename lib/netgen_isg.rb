require 'netgen'

class ISGRootGraph < SimpleGraph
  include Neighborly
  def initialize g
    super()
    @edges = g.edges
    @nodes = []
    put_nodes(g)
    set_neighbors
    set_two_neighborhood
  end

  def put_nodes g
  end
end

class ISGGraph < ISGRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(ISGNode.new(k))}
  end
end
