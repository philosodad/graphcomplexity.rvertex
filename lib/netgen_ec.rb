require 'netgen'
require 'node_ec'

class EdgeColorGraph < MatchGraph
  def get_node_type
    Object.const_get('EdgeColorNode')
  end
end
