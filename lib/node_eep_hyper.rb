require 'node_eep'

class DeepsHyperNode < DeepRootNode
  def set_edges
    kn = {}
    kn[id] = self
    @neighbors.each{|k| kn[k.id] = k}
    eds = Set[]
    @edges.each do |k|
      edge = []
      k.each{|j| edge.push kn[j]}
      eds.add(DeepsHyperEdge.new(edge))
    end
    @edges = eds
  end
end
    
