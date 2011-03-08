require 'netgen_tgt'
require 'node_eep_hyper'

class DeepsHyperGraph < TargetGraph

  def get_node_type
    return Object.const_get 'DeepsHyperNode'
  end

  def reset
    @nodes.select{|k| k.on}.select{|k| k.weight == 0}.each{|k| k.set_next(:covertargets); k.set_now(:covertargets)}
  end

  def coverable?
    @nodes.select{|k| k.edges.select{|j| j.supply == 0}.any?}.empty?
  end
end
