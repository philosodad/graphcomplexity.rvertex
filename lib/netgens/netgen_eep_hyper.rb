require 'netgen_tgt'
require 'node_eep_hyper'

class DeepsHyperGraph < TargetGraph
  include Connectable
  def initialize *args
    super 
    until connect?
      x,y = coord_within_distance(@nodes.sample, $distance)
      @nodes.push(get_node_type.new(x,y))

      add_single_node(get_node_type.new(coord_within_distance()))
      set_neighbors
      set_edges
    end
  end

  def get_node_type
    return Object.const_get 'DeepsHyperNode'
  end

  def reset
    reduce_by_min
    @nodes.select{|k| k.on}.select{|k| k.weight == 0}.each{|k| k.set_next(:covertargets)}
  end
end
