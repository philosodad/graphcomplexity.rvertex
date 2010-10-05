require 'node'

class LDGRootNode < BasicNode
  include VCLocal
  include LDG_Cover_Acts
  include BasicAutomata
  def initialize
    super()
    @currentcover = 0
    @booted = false
    @next = :analyze
    @round = 0
    init_covers
  end
  
  def init_covers
    @covers = LdGraph.new(Set[], [])
  end

  def compare_ons? newList
    these = Set.new(@onlist.keys)
    those = Set.new(newList.keys)
    boths = these.intersection(those)
    boths.each{|k| return false unless newList[k] == @onlist[k]}
    return true
  end  
end

class LDGNode < LDGRootNode
  include LDG_Standard_Acts
  def initialize(x,y)
    super()
    @x = x
    @y = y
  end
end

class LDGRedNode < LDGRootNode
  include LDG_Red_Acts
  include Redundant
  def initialize *args
    if args.length == 1
      super()
      n = args[0]      
      x = n.x
      x = n.y
      w = n.weight
      i = n.id
    else
      super()
      x = args[0]
      y = args[1]
      i = nil
      w = nil
    end
    @x = x
    @y = y
    @weight = w unless w == nil
    @id = i unless i == nil
    @redundant = false
  end
end

class LDGShortRedNode < LDGRedNode
  include VCLocalShort
  def init_covers
    @covers = ShortLifeLdGraph.new(Set[],[])
  end
end

class SetNode < LDGNode
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

class CoverNode < LDGNode
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
    n = Set[]
    @neighbors.each do |k|
      k.neighbors.each do |j|
        j.neighbors.each do |i|
          n.add(i)
        end
        n.add(j)
      end
    end
    alledges = Set[]
    @neighbors.each do |k|
      k.neighbors.each do |j|
        j.edges.each{|i| alledges.add(i)}
      end
      k.edges.each{|l| alledges.add(l)}
    end
    c = construct_covers n, alledges
    @covers = LdGraph.new(c, n)
  end
end
