$:.unshift File.join(File.dirname(__FILE__),'..','lib','actions')
require 'set'
require 'cover'
require 'ldgraph'
require 'automata'
require 'gmm'
require 'weighted_edge'
require 'helpers_node'
require 'actions_ldg'
require 'globals.rb'

class BaseNode
  attr_reader :x, :y, :id, :edges, :next, :now
  attr_accessor :neighbors
  @@id = 0

  def initialize
    @neighbors = []
    @edges = Set[]
    @id
    @next
    @now
    @x
    @y
    update_id
  end

  def update_id
    @id = @@id
    @@id += 1
  end

  def set_now symb
    @now = symb
  end
  
  def set_next symb
    @next = symb
  end
  
  def do_next
  end
  def send_status
  end
  def recieve_status
  end

  def zero_out
    @@id = 0
  end

end
  
class BasicNode < BaseNode
  include Weighted
  include OnOffAble
  attr_reader :covers, :onlist, :currentcover, :booted
  attr_accessor :on, :onlist
  @@id = 0
  def initialize
    super
    init_onoff
    init_weight
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
    set_ons
  end

  def remove_neighbor node
    @neighbors.delete(node)
  end


  def remove_self
  end
  
end

class SimpleNode < BasicNode
  include SimpleVC
  def initialize(x,y)
    super()
    @x = x
    @y = y
    @covers = init_covers
    @weight = rand($init_weight) + ($init_range)
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


