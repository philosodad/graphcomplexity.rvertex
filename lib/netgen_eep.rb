require 'netgen_pcd'
require 'node_eep'

class DeepsRootGraph < PCDRootGraph
  def reset
    @nodes.each do |k|
      k.set_next :boot
      k.set_now :boot
      k.on = nil
      if k.weight == 0
        k.on = false
      end
    end
  end
end

class DeepsGraph < DeepsRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(DeepsNode.new(k))}
  end
end
