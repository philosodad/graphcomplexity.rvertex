require 'node_match'

class EdgeColorRootNode < MatchNode
  def initialize *args
    case args.length
    when 1
      begin
        args[0] = n
        raise TypeError unless n.kind_of?(BasicNode)
        id = n.id
      rescue => ex
        puts "#{ex.class}: With one argument, you must pass a node"
      end         
    when 2
      id = nil
    end
    super
    @id = id unless id == nil
    @weight = nil
    @next = :something
    @colors = []
    build_color_list
  end

  def build_color_list
    (0..2**12).each{|k| @colors.push k}
  end

  def get_node_type
    Object.const_get("ColoredEdge")
  end
end
