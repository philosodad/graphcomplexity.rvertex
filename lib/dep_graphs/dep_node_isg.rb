require 'dep_node'

class ISG_Graph_Node < Dep_Node_Root
  attr_reader :degree
  def initialize n, nodes
    super
    @degree = 0
  end

  def set_degree d
    @degree = d
  end

  def <=> b
    if @degree < b.degree
      return -1
    elsif @degree > b.degree
      return 1
    elsif @weight < b.weight
      return -1
    elsif @weight > b.weight
      return 1
    elsif @id < b.id
      return -1
    else
      return 1
    end
  end
end
