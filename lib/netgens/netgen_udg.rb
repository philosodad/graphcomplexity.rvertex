require 'netgen'

class UDG_Graph < SimpleGraph
  include PlanarMath
  include Connectable
  include UnitDiskNeighborly
  def initialize(n,deg)
    super()
    add_nodes(n,deg)
    set_neighbors
    set_edges
  end
  
  def get_node_type
    return Object.const_get('SimpleNode')
  end

  def set_edges
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end
end
