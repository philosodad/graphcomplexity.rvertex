require 'node_match'
require 'actions_ec'
require 'actions_dec'

class EdgeColorRootNode < MatchRootNode
  include Colorable
  def initialize *args
    case args.length
    when 1
      begin
        n = args[0]
        raise TypeError unless n.kind_of?(BaseNode)
      rescue => ex
        puts "#{ex.class}: With one argument, you must pass a node"
      ensure
        id = n.id
        x = n.x
        y = n.y
      end         
    when 2
      id = nil
      x = args[0]
      y = args[1]
    end
    super()
    @invites = {}
    @x = x
    @y = y
    @id = id unless id == nil
    @next = :choose
    init_colors(12)
  end

  def get_edge_type
    Object.const_get("ColoredEdge")
  end
end

class EdgeColorNode < EdgeColorRootNode
  include EcActs
  include Ec_Deciders
end

class DirectedEdgeColorNode < EdgeColorRootNode
  include Dec_Acts
  include Dec_Deciders
  include Compare_by_Edge
  include Message_Passer
  include Directional_Colorable

  def initialize *args
    super
    @invites = []
    @next_message = nil
  end
    
  def get_edge_type
    Object.const_get("DirectedColorEdge")
  end
end
