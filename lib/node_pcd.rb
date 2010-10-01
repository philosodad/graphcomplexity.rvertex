require 'node'
require 'actions_pcd'
require 'helpers_node'

class PCDRoot < BasicNode
  include PCD
  include Comparable
  def initialize(*args)
    if args.size == 1 then
      if args[0].kind_of?(BasicNode) then
        x = args[0].x
        y = args[0].y
        weight = args[0].weight
        id = args[0].id
      else 
        x = 0
        y = 0
        id = 
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
    @on = nil
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
  
  def burn_cover node
    @covers.burn_cover node
  end
  

  def <=>(other)
    return nil unless other.instance_of? self.class
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

class PCDRedundant < PCDRoot
  include Redundant
end

class PCDNode < PCDRedundant
  include PCD
  include PCD_One_Acts
end


class PCDDeltaNode < PCDNode
  include PCD_Delta_Acts
end

class PCDAllNode < PCDRedundant
  include PCDAll
  include PCD_All_Acts
  def initialize *args
    super(*args)
    @cur = 0
  end

  def burn_cover node
    @covers.nodes.sort!
  end
end

class PCDNodeSum < PCDAllNode
  include PCD_All_Sum
end

class PCDNodeMinRed < PCDAllNode
  include Redundant_Min
end

class PCDAllNodeNoRed < PCDAllNode
  include PCD_All_Acts_No_Red
end
