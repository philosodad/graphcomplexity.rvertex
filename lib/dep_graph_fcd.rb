require 'dep_node_fcd'
require 'dep_graph'

class FCD_Graph < Dep_Graph_Root
  def get_node_type
    return Object.const_get('FCD_Graph_Node')
  end
end
