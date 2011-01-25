require 'netgen_tgt'
require 'node_eep_hyper'

class DeepsHyperGraph < TargetGraph
  def get_node_type
    return Object.const_get 'DeepsHyperNode'
  end
end
