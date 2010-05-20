require 'set'
require 'cover'
require 'ldgraph'
require 'automata'
require 'gmm'
require 'weighted_edge'

class BasicNode
  attr_reader :x, :y, :id, :edges, :covers, :onlist, :currentcover, :neighbors, :booted, :next, :now
  attr_accessor :neighbors, :weight, :on
  @@id = 0
  def initialize
    @on = nil
    @neighbors = []
    @edges = Set[]
    @id
    @next
    @now
    updateid
  end

  def do_next
  end
  def send_status
  end
  def recieve_status
  end

  def updateid
    @id = @@id
    @@id += 1
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
  end

  def zero_out
    @@id = 0
  end
  
end

class MatchNode < BasicNode
  include DGMM
  def initialize(*args)
    if args.size == 1 then
      if args[0].class == Node then
        x = args[0].x
        y = args[0].y
        weight = args[0].weight
      else 
        puts "with one argument, you should pass a Node"
      end
    elsif args.size == 2 then
      x = args[0]
      y = args[1]
      weight = rand(50) + 50
    end
    super()
    @x = x
    @y = y
    @weight = weight
    @next = :choose
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
    e = @edges.to_a
    @edges = Set[]
    e.each{|k| @edges.add(WeightedEdge.new(k))}
  end

  def do_next
    @now = @next
    case @now
    when :invite
      @next = :wait
    when :respond
      @next = :choose
    when :listen
      return true
    when :wait
      return true
    when :choose
      return true
    end
  end

 

  def send_status
    case @now
    when :invite
      e = choose_edge
      if e == :empty then 
        @next = :saturated
      else
        @next = :listen
        i = (e.uv - Set[@id]).first
        n = @neighbors.select{|k| k.id == i}
        n.recieve_status
      end
    when :respond
    when :listen, :wait
      return true
    when :choose
      choose_role
    end
  end

  def recieve_status
  end
      
  def check_battery
    return 100-@weight
  end
  
end

class Node < BasicNode
  include VCLocal
  include BasicAutomata
  def initialize(x,y)
    super()
    @x = x
    @y = y
    @covers = LdGraph.new(Set[], [])
    @weight = rand(50)+50
    @currentcover = 0
    @onlist = {}
    @booted = false
    @next
  end
  
  def boot
    if @booted 
      return true
    else
      if !@neighbors
        return :fail
      else
        set_edges
        @booted = true
        @neighbors.each do |k|
          if !k.booted
            k.boot
          end
        end
        set_covers
        set_ons
        return true
      end
    end
  end

  def set_covers
    @covers = build_covers unless @edges.empty?
  end

  def set_ons
    @neighbors.each{|k| @onlist[k.id] = k.on}
  end
  
  def compare_ons? newList
    these = Set.new(@onlist.keys)
    those = Set.new(newList.keys)
    boths = these.intersection(those)
    boths.each{|k| return false unless newList[k] == @onlist[k]}
    return true
  end

  def update_covers_on id, status
    if @onlist[id] != status then
      @onlist[id] = status
      @covers.ldnodes.each do |k|
        if k.cover.include?(id) then 
          status ? k.onremain += 1 : k.onremain -=1
        end
      end
    end
  end

  def sort_covers
    @covers.ldnodes.each{|k| k.set_onremain(@neighbors + [self])}
    @covers.ldnodes.sort!
  end
  
  def send_initial
    start = -1
    start = @covers.ldnodes[@currentcover].cover.min unless @covers.ldnodes[@currentcover] == nil
    if start == @id
      @next = :sendon
      return true
    else
      @next = :continue
      return false
    end
  end

  def do_next
    @now = @next
    case @now
    when :continue, nil
      return true
    when :sendoff
      @next = :continue
      @on = false
    when :sendon
      @next = :continue
      @on = true
    when :oddfail
      return false
    end
  end
  
  def send_status
    case @now
    when :sendon, :sendoff
      @neighbors.each{|k| k.recieve_status(@id, @on)}
      return true
    end
    return false
  end
  
  def recieve_status id, status
    @next = transition id, status
  end
end

class SetNode < Node
  def initialize(id)
    super(0,0)
    @id = id
  end
  
  def updateid
  end
end
