require 'node'
require 'actions_dumb'

class DumbRootNode < BasicNode
  def initialize
    super()
    @next = :analyze
  end
end

class DumbNodeRed < DumbRootNode
  include Redundant
  include Dumb_Acts_Red
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
