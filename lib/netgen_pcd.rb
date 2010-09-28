require 'netgen'

class PCDRootGraph < SimpleGraph
  include Neighborly
  def initialize g
    super()
    @edges = g.edges
    @nodes = []
    put_nodes(g)
    set_neighbors
  end

  def put_nodes g
  end

  def reset
    @nodes.each do |k|
      k.redundant = false
      if k.weight == 0 then
        k.on = false
        k.neighbors.each{|j| j.on = true}
      end
      k.set_now(:decided)
      k.set_next(:decided)
    end
  end

end

class PCDAllGraph < PCDRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(PCDAllNode.new(k))}
  end
end

class PCDAllGraphNoRed < PCDRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(PCDAllNodeNoRed.new(k))}
  end
end

class PCDDeltaGraph < PCDRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(PCDDeltaNode.new(k))}
  end
end

class PCDGraph < PCDRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(PCDNode.new(k))}
  end
end
