require 'set'
require 'cover'
require 'ldgraph'
require 'automata'
class Node
  include VCLocal
  include BasicAutomata
  attr_reader :x, :y, :id, :edges, :covers, :onlist, :currentcover, :neighbors, :booted, :next, :now
  attr_accessor :neighbors, :weight, :on
  @@id = 0
  def initialize(x,y)
    @on = nil
    @x = x
    @y = y
    @id
    @neighbors = []
    @edges = Set[]
    updateid
    @covers
    @weight = rand(50)+50
    @currentcover = 0
    @onlist = {}
    @booted = false
    @next = []
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



  def updateid
    @id = @@id
    @@id += 1
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
  end

  def set_covers
    @covers = build_covers
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
    start = @covers.ldnodes[@currentcover].cover.min
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

  def zero_out
    @@id = 0
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
