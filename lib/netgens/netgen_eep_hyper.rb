require 'netgen_tgt'
require 'node_eep_hyper'

class DeepsHyperGraph < TargetGraph

  def get_node_type
    return Object.const_get 'DeepsHyperNode'
  end

  def reset
    reduce_by_min
    @nodes.select{|k| k.on}.select{|k| k.weight == 0}.each{|k| k.set_next(:covertargets)}
  end
end
