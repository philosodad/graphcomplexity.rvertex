require 'set'
require 'cover'
require 'ldgraph'
require 'automata'
require 'gmm'
require 'weighted_edge'
require 'helpers_node'

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
    @weight = rand(5000) + 5000
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

class Node < BasicNode
  include VCLocal
  include BasicAutomata
  def initialize(x,y)
    super()
    @x = x
    @y = y
    @covers = LdGraph.new(Set[], [])
    @currentcover = 0
    @booted = false
    @next = :analyze
    @round = 0
  end
  
  def set_covers
    @covers = build_covers unless @edges.empty?
  end

  def burn_cover node
    @covers.burn_cover node, [self]+@neighbors-[node]
  end
  
  def compare_ons? newList
    these = Set.new(@onlist.keys)
    those = Set.new(newList.keys)
    boths = these.intersection(those)
    boths.each{|k| return false unless newList[k] == @onlist[k]}
    return true
  end

  def update_covers_on
    @covers.ldnodes.each do |k|
      k.onremain = k.cover.length
      k.cover.each{|j| if @onlist[j] == true then k.onremain -= 1 end}
    end
  end

  def sort_covers
    @covers.ldnodes.each{|k| k.set_onremain(@neighbors + [self])}
    @covers.ldnodes.sort!
  end

  def do_next
    curcov = @covers.ldnodes[@currentcover]
    if curcov == nil then
      sort_covers
      @currentcover = 0
    end
    if @covers.ldnodes.length == 0 then
      puts "#{@id} has no remaining covers"
    end
    @now = @next
    case @now
    when :analyze
      if highest_priority? then
        @on = true
        @onlist[@id] = true
        @now = :sendon
        @next = :done
      elsif out_of_cover? and covered? and @on == nil
        @on = false
        @onlist[@id] = false
        @now = :sendoff
        @next = :done
      elsif @on != nil
        @next = :analyze
      end
    when :change_cover
      @currentcover += 1
      @currentcover = @currentcover%@covers.ldnodes.length
      @next = :analyze
    when :out_of_batt
      @next = :out_of_batt
    end
    @round += 1
  end

  
  def send_status
    case @now
    when :sendon, :sendoff
      @neighbors.each{|k| k.recieve_status(@id, @on)}
    end
  end
  
  def recieve_status id, status
    @next = transition id, status unless @now == :out_of_batt
  end
end

class SetNode < Node
  def initialize(x)
    if x.class == Fixnum then
      super(0,0)
      @id = x
    elsif x.class == Node then
      super(x.x, x.y)
      @id = x.id
      @weight = x.weight
    end
  end
  
  def update_id
  end
end

class SetNodeObs < SetNode
  include VCLocal_Obs
end

class CoverNode < Node
  include CoverComposer
  def initialize *args
    if args.length == 2
      super(args[0], args[1])
    elsif args.length == 1
      super(0,0)
      @id = args[0].id
      @weight = args[0].weight
    end
  end
  def set_covers
    n = @neighbors + [self]
    alledges = Set[]
    @edges.each{|k| alledges.add(k)}
    nset = Set.new(@neighbors.collect{|k| k.id})
    nset.add(@id)
    @neighbors.each do |k| 
      k.edges.each do |j| 
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    c = construct_covers n, alledges
    @covers = LdGraph.new(c, n)
  end
end

