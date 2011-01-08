require 'node'
require 'actions_match'

class MatchRootNode < BaseNode
  attr_reader :rp, :invites
  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
    e = @edges.to_a
    @edges = Set[]
    e.each{|k| @edges.add(get_edge_type.new(k))}
  end

  def get_edge_type
  end
end

class MatchNode < MatchRootNode
  attr_reader :subtract
  include OnOffAble
  include Weighted
  include DGMM_min
  include Match_Acts
  def initialize(*args)
    if args.size == 1 then
      if args[0].kind_of?(BaseNode) then
        x = args[0].x
        y = args[0].y
        weight = args[0].weight
        id = args[0].id
      else 
        raise TypeError, "with one argument, you should pass a Node"
      end
    elsif args.size == 2 then
      x = args[0]
      y = args[1]
      weight = init_weight
      id = nil
    end
    super()
    @invites = []
    init_onoff
    @id = id unless id == nil
    @x = x
    @y = y
    @weight = weight unless weight == nil
    @next = :choose
    @rp = nil
    @subtract = 0
  end

  def get_edge_type
    return Object.const_get("WeightedEdge")
  end

  def reset
    @edges.each{|k| k.weight = nil}
    @subtract = 0
    @rp = nil
    @next = :choose
    @now = nil
    @invites = []
    @on = nil
  end
        
  def set_now sym
    @now = sym
  end

  def set_rp node
    @rp = node
  end

  def set_next sym
    @next = sym
  end
end

class MatchMaxNode < MatchNode
  include DGMM_max
end

class MatchMWMNode < MatchNode
  include DGMM_mwm
end

class MatchRedNode < MatchNode
  include Redundant
  include DGMM_red
  include Match_Red_Acts
  def initialize *args
    super(*args)
    @redundant = false
  end
end
