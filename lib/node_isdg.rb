require 'node_pcd'
require 'cover'

class ISDGRoot < PCDRoot
  include IS_Combinator
  def get_dep_graph_type
    return Object.const_get('IS_Graph')
  end
end
