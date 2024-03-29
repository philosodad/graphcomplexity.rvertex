require 'node_pcd'
require 'cover'
require 'dep_graph_isg'

class ISDGRoot < PCDRoot
  include IS_Combinator
  def get_dep_graph_type
  end
end

class ISGNode < ISDGRoot
  attr_accessor :neighborhood
  def initialize *args
    super
    @neighborhood = []
  end
  def get_dep_graph_type
    return Object.const_get('ISG_Graph')
  end
end
