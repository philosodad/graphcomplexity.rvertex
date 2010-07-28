require 'node'
require 'actions_pcd'
class PCDNode < BasicNode
  include PCD
  include Comparable
  include PCD_OneCheck
  attr_reader :redundant
  def initialize(*args)
    if args.size == 1 then
      if args[0].class == Node or args[0].class == SetNode then
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
      weight = nil
      id = nil
    end
    super()
    @id = id unless id == nil
    @x = x
    @y = y
    @weight = weight unless weight == nil
    @next = :analyze
    @covers = init_covers
    @onlist = Set[]
    @offlist = Set[]
    @redundant = false
  end

  def off?
    if @on == true or @on == nil
      return false
    else
      return true
    end
  end

  def init_covers
    return PCD_Graph.new
  end
  

  def <=>(other)
    return nil unless other.instance_of? PCDNode
    if @weight < other.weight
      return -1
    elsif @weight > other.weight
      return 1
    elsif @id < other.id
      return -1
    else
      return 1
    end
  end

  def check_finished
    if @neighbors.select{|k| k.now == :decided or k.now == :finish}.length == @neighbors.length
      if @on
        if @neighbors.select{|k| !k.on}.empty?
          @redundant = true
        end
      end
      @next = :finish
    else
      @next = :decided
    end
  end

  def check_redundant
    if @neighbors.select{|k| k.now == :finish or k.now == :done}.length == @neighbors.length
      if @redundant
        if @neighbors.select{|k| k.redundant}.empty?
          @on = false
        else
          a = @neighbors.select{|k| k.redundant} + [self]
          if a.max == self
            @on = false
          end
        end
      end
      @next = :done
    else
      @next = :finish
    end  
  end
end

class PCDDeltaNode < PCDNode
  include PCD_DeltaCheck

  def <=>(other)
    return nil unless other.instance_of? PCDDeltaNode
    if @weight < other.weight
      return -1
    elsif @weight > other.weight
      return 1
    elsif @id < other.id
      return -1
    else
      return 1
    end
  end
  
end
