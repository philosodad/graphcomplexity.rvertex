require 'node'
require 'helpers_node'
require 'node_pcd'
require 'actions_fcd'
require 'actions_pcd'
require 'dep_graph_fcd'

class FCDRootNode < PCDRoot
  include Combinator
  include PCD_All_Acts
  include FCD_Acts
  attr_accessor :neighborhood
  def initialize *args
    super(*args)
    @cur = 0
    @neighborhood = []
  end

  def init_covers *args
    return get_dep_graph_type.new([],[])
  end
    
  def get_dep_graph_type
    return Object.const_get('FCD_Graph')
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
  end
end

class FCDRedNode < FCDRootNode
  include Redundant
end    
