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
      if k.weight == 0 then
        k.on = false
        k.neighbors.each{|j| j.on = true}
        k.set_now(:decided)
        k.neighbors.each do |j| 
          j.set_next(:decided)
          j.redundant = false
          j.neighbors.each do |l| 
            l.set_next(:decided)
            l.redundant = false
          end
        end
        k.redundant = false

      end
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
