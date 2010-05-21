require 'set'
require 'cover'
require 'ldgraph'
require 'automata'
require 'gmm'
require 'weighted_edge'

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
    set_ons
  end

  def set_ons
    @neighbors.each{|k| @onlist[k.id] = k.on}
    @onlist[@id] = @on
  end

  def zero_out
    @@id = 0
  end
  
end

class MatchNode < BasicNode
  attr_reader :rp, :subtract, :invites
  include DGMM_min
  def initialize(*args)
    if args.size == 1 then
      if args[0].class == Node then
        x = args[0].x
        y = args[0].y
        weight = args[0].weight
        id = args[0].id
      else 
        puts "with one argument, you should pass a Node"
      end
    elsif args.size == 2 then
      x = args[0]
      y = args[1]
      weight = rand(50) + 50
    end
    super()
    @tid = @id
    @id = id
    @x = x
    @y = y
    @weight = weight
    @next = :choose
    @rp = nil
    @invites = []
    @subtract = 0
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
      @next = :update
    when :listen
      @next = :respond
      return true
    when :wait
      @next = :update
      return true
    when :update
      update_weight
      @next = :exchange
    when :exchange
      update_edges
      @next = :choose
    when :choose
      choose_role
    when :done
      @next = :done
    end
  end

 

  def send_status
    case @now
    when :invite
      e = choose_edge
      if e == :empty then 
        return true
      else
        i = (e.uv - Set[@id]).first
        @rp = @neighbors.select{|k| k.id == i}.first
        @rp.recieve_status (@id)
      end
    when :respond
      if not @invites.empty? then
        n = @invites[rand(@invites.length)]
        @rp = @neighbors.select{|k| k.id == n}.first
        @neighbors.each{|k| k.recieve_status (@rp.id)}
        @subtract = [check_battery, @rp.check_battery].min
      end
    when :choose
      @subtract = 0
      @rp = nil
    when :listen, :wait
      return true
    end
  end

  def recieve_status id
    case @now
    when :listen
      add_invite(id)
      return true
    when :wait
      if id == @id
        @subtract = [check_battery, @rp.check_battery].min
      end
      return true
    else
      return false
    end
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

class Node < BasicNode
  include VCLocal
#  include BasicAutomata
  include BasicAutomata
  def initialize(x,y)
    super()
    @x = x
    @y = y
    @covers = LdGraph.new(Set[], [])
    @weight = rand(50)+50
    @currentcover = 0
    @booted = false
    @next
  end
  
  def set_covers
    @covers = build_covers unless @edges.empty?
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
    when :continue
      if @covers.ldnodes[@currentcover].has?(@id) then
        a = @covers.ldnodes[@currentcover].cover.to_a
        a = a.select{|k| @onlist[k] == nil}.min
        if a == @id
          @on = true
          @now = :sendon
          @next = :done
        end
      else
        a = @covers.ldnodes[@currentcover].cover.to_a
        a = a.select{|k| @onlist[k] != true}
        if a.empty?
          @on = false
          @now = :sendoff
          @next = :done
        end
      end unless @on != nil        
      return true
    when :sendoff
      @next = :done
      @on = false
      @onlist[@id] = @on
    when :sendon
      @next = :done
      @on = true
      @onlist[@id] = @on
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
