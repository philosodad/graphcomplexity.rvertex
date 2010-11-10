require 'node_pcd'
require 'cover'

class ISDGRoot < PCDRoot
  include IS_Combinator
  def get_dep_node_type
    return Object.const_get('IS_Graph')
  end
end
