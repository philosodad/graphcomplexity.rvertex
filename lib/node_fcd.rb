require 'node'
require 'helpers_node'
require 'node_pcd'
require 'actions_fcd'
require 'actions_pcd'
require 'dep_graph_fcd'

class FCDRootNode < PCDRoot
  include Combinator
  include PCD_All_Acts
  include FCD_Acts

  def initialize *args
    super(*args)
    @cur = 0
  end

  def init_covers *args
    return get_dep_graph_type.new([],[])
  end
    
  def get_dep_graph_type
    return Object.const_get('FCD_Graph')
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
  end

  def set_covers
    n = Set[]
    @neighbors.each do |k|
      k.neighbors.each do |j|
        n.add(j)
      end
      n.add(k)
    end
    alledges = Set[]
    @neighbors.each do |k|
      k.edges.each{|l| alledges.add(l)}
    end
    puts "covers will now be constructed for #{n.length} nodes covering #{alledges.length} edges"
    c = construct_covers n, alledges
    @covers = get_dep_graph_type.new c, n
#    puts "One cover has been created"
  end
end

class FCDRedNode < FCDRootNode
  include Redundant
end    
