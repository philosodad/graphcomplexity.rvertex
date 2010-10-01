require 'helpers_dep_node'

class PCD_Graph_Node_Root
  @@id = 0
  include Comparable
  attr_reader :ids, :weight, :id, :keyed_weights
  attr_accessor :degree
  def initialize(nodes)
    @ids = nodes.collect{|k| k.id}
    @weight = set_weight(nodes)
    @keyed_weights = {}
    nodes.each{|k| @keyed_weights[k.id] = k.weight}
    @degree = 0
    @id = @@id
    @@id += 1
  end

  def set_weight(nodes)
  end

  def <=>(b)
    if @weight < b.weight then
      return -1
    elsif @weight > b.weight then 
      return 1
    elsif @degree > b.degree then
      return -1
    elsif @degree < b.degree then
      return 1
    elsif @id < b.id then
      return -1
    elsif @id > b.id then
      return 1
    else 
      return -1
    end
  end

  def reduce_weight w
    @weight -= w
  end

  def zero_out
    @@id = 0
  end
end

class PCD_Graph_Node < PCD_Graph_Node_Root
  include Minimum_Weight
end

class PCD_Graph_Node_Sum < PCD_Graph_Node_Root
  include Cumulative_Weight
end

class PCD_Bipartite_Graph_Node < PCD_Graph_Node

end
