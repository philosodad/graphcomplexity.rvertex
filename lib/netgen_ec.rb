require 'netgen'
require 'node_ec'

class EdgeColorGraph < MatchGraph
  def get_node_type
    Object.const_get('EdgeColorNode')
  end
end

class DirectedEdgeColorGraph < MatchGraph
  def get_node_type
    Object.const_get('DirectedEdgeColorNode')
  end
end
