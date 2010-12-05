require 'dep_node'
require 'helpers_netgen'
require 'helpers_dep_node'
require 'set'

class Dep_Graph_Root
  include Neighborly
  include Cleanable
  attr_reader :nodes, :edges
  def initialize c, n
    @nodes = []
    @edges = []
    make_nodes c, n
    make_edges
    set_neighbors
  end
  
  def make_nodes c,n
    if !c.empty? then
      c = kill_redundant c
      c.each{|k| @nodes.push(get_node_type.new(k,n))}
      @nodes.sort!
    end
  end

  def get_node_type
    return Object.const_get('Dep_Node_Root')
  end

  def make_edges 
    e = Set[]
    n = @nodes.dup
    n.length.times do
      a = n.shift
      n.each{|k| if a.ids - k.ids != a.ids then e.add(Set[a.id, k.id]) end}
    end
    @edges = e.to_a
  end  
end
