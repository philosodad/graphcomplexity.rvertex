require 'netgen'

class DumbRootGraph < RandomGraph
  def initialize(*args)
    if args.length == 1
      g = args[0]
      @edges = g.edges
      @nodes = []
      put_nodes(g)
      set_neighbors
    else
      super(args[0], args[1])
    end
  end
  
  def add_nodes n
    n.times{@nodes.push(DumbRootNode.new(0,0))}
  end

  def put_nodes g
    g.nodes.each{|k| @nodes.push(DumbRootNode.new(k))}
  end
end

class DumbRedGraph < DumbRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(DumbNodeRed.new(k))}
  end
  def add_nodes n
    n.times{@nodes.push(DumbNodeRed.new(0,0))}
  end
end
