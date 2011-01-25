#Dependency Graph for Independent Set

require 'dep_node_isg'
require 'dep_graph'

class ISG_Graph < Dep_Graph_Root
  def initialize
    super
    @current_cover = @nodes[0]
    set_degrees
  end

  def get_node_type
    return Object.const_get('ISG_Graph_Node')
  end

  def set_degrees
    @nodes.each do |k|
      d = 0
      k.neighbors.each do |j|
        d += (k.ids & j.ids).length
      end
      k.set_degree d
    end
  end
end

