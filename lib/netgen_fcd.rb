require 'netgen'
require 'netgen_pcd'

class FCDRootGraph < PCDRootGraph
  
end

class FCDRedGraph < FCDRootGraph
  def initialize g
    super
    set_two_neighborhood
  end
  def put_nodes g
    g.nodes.each{|k| @nodes.push(FCDRedNode.new(k))}
  end
end
