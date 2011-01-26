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

  def get_number_colors
    m = []
    @nodes.each do |j|
      j.edges.each do |k|
        m = m + k.color.values
      end
    end
    m.uniq!
    m.length
  end
end
