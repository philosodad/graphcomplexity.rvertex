require 'set'
require 'cover'
require 'ldgraph'
require 'automata'
require 'gmm'
require 'weighted_edge'
require 'helpers_node'
require 'actions_ldg'

class BasicNode
  attr_reader :x, :y, :id, :edges, :covers, :onlist, :currentcover, :neighbors, :booted, :next, :now
  attr_accessor :neighbors, :weight, :on, :onlist
  @@id = 0
  def initialize
    @on = nil
    @neighbors = []
    @edges = Set[]
    @id
    @next
    @now
    @onlist = {}
    @keyedweights = {}
    @weight = rand(400) + 600
    update_id
  end

  def do_next
  end
  def send_status
  end
  def recieve_status
  end

  def update_id
    @id = @@id
    @@id += 1
  end

  def off?
    if @on == false
      return true
    else
      return false
    end
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
    set_ons
  end

  def set_ons
    @neighbors.each{|k| @onlist[k.id] = k.on}
    @onlist[@id] = @on
    @neighbors.each{|k| @keyedweights[k.id] = k.weight}
    @keyedweights[@id] = @weight
  end

  def remove_neighbor node
    @neighbors.delete(node)
  end

  def set_now symb
    @now = symb
  end

  def set_next symb
    @next = symb
  end

  def remove_self
  end

  def zero_out
    @@id = 0
  end
  
end

class SimpleNode < BasicNode
  include SimpleVC
  def initialize(x,y)
    super()
    @x = x
    @y = y
    @covers = init_covers
    @weight = rand(50)+50
    @currentcover = 0
  end

  def init_covers
    return SimpleLdGraph.new(Set[], [])
  end

  def set_covers
    @covers = build_covers unless @edges.empty?
  end
end

class TotalWeightNode < SimpleNode
  include TotalWeightVC
  def init_covers
    return TotalWeightLdGraph.new(Set[], [])
  end
end

class DegreeWeightNode < SimpleNode
  include DegreeWeightVC
  def init_covers
    return DegreeWeightLdGraph.new(Set[], [])
  end
end

class ShortLifeNode < SimpleNode
end


