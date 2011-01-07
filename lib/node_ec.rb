require 'node_match'
require 'actions_ec'

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
