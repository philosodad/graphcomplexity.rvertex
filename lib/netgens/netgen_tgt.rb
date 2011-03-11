require 'netgen'

class TargetGraph < SimpleGraph
  include PlanarMath
  include Targetable

  def initialize *args
    if args.length == 2 
      n = args[0]
      t = args[1]
      if args[0].class == Fixnum
        raise ArgumentError, "#{t} must be less than #{n}!" unless args[1] <= (1..n).inject(:*)
      elsif args[0].class == Array
        ns = args[0].length
        ts = args[1].length
        raise ArgumentError, "#{ts} must be less than #{ns}!" unless ts <= (1..ns).inject(:*)
      end
      super()
      nodes, targets = build_connectable_graph(n,t)
      add_nodes nodes
      @edges = build_edges targets
    elsif args.length == 1
      raise TypeError, "g must be kind of TargetGraph" unless args[0].kind_of?(TargetGraph)
      g = args[0]
      super()
      g.nodes.each{|k| add_single_node(k)}
      @edges = g.edges
    end
    set_neighbors
    set_edges
  end

  def add_nodes nodes
    nodes.each{|k| @nodes.push(get_node_type.new(k.x, k.y))}
  end

  def add_single_node n
    @nodes.push(get_node_type.new(n))
  end

  def get_node_type
    return Object.const_get('HyperNode')
  end

  def set_neighbors
    kn = {}
    @nodes.each{|k| kn[k.id] = k}
    @edges.each do |t|
      (0...t.cover.length-1).each do |a|
        (a+1...t.cover.length).each do |b|
          kn[t.cover[a]].neighbors.push(kn[t.cover[b]])
          kn[t.cover[b]].neighbors.push(kn[t.cover[a]])
          [kn[t.cover[a]],kn[t.cover[b]]].each do |c|
            c.neighbors.uniq!
            c.neighbors.compact!
          end
        end
      end
    end
  end

  def set_edges
    @edges.each do |k|
      if k.cover.empty? then p "I AM A WALRUS" end
      @nodes.each do |j|
        if k.cover.include? j.id then
          j.edges.add(k)
        end
      end
    end
  end

  def add_edges t
    @edges = build_connectable_edges t 
    attempts = 0
    while @edges == nil or @edges.length < t
      raise StandardError, "Target requirement unfulfilled in #{$space**2} attempts" unless attempts < $space**2
      @edges += build_edges 1
      attempts += 1
    end
  end
  
  def build_edges targets
    exis = add_from_to_by @nodes, targets, 'x'
    whys = add_from_to_by @nodes, targets, 'y'
    targets.each do |k|
      eds = (exis[k]&whys[k])
      k.cover += (eds.select{|j| planar_distance(j, k) <= $sensor_range}.collect{|j| j.id})
      k.cover.uniq!
      if k.cover.empty? then raise StandardError, "this target has no nodes in range" end
    end
    targets
  end

  def get_lower_bound
    edgeweights = []
    keyednodes = {}
    @nodes.each{|k| keyednodes[k.id] = k.weight}
    @edges.each do |k|
      w = 0
      k.cover.each{|j| w += keyednodes[j]}
      edgeweights.push(w)
    end
    return edgeweights.min
  end
  
  def coverable?
    kn = {}
    @nodes.each{|k| kn[k.id]=k}
    @edges.select{|k| k.cover.inject(0){|sum,n| kn[n].weight + sum} == 0}.empty? 
  end

  def covered?
    onlist = @nodes.select{|j| j.on and j.weight > 0}.collect{|k| k.id}
    @edges.select{|k| (k.cover & onlist).empty?}.empty?
  end

  def connect?
    true
  end
  def connectable?
    true
  end

  def print_out
    puts "nodes: #{@nodes.collect{|k| [k.id, k.x, k.y, k.weight, k.edges.collect{|j| j.ids}]}}\n
      edges: #{@edges.collect{|k| [k.x, k.y, k.cover]}}
      on: #{nodes.select{|k| k.on}.collect{|k| k.id}}"
  end
end

class SetTargetGraph < TargetGraph

  def initialize n,t
    super(n,t)
  end

  def add_nodes n
    n.each{|k| @nodes.push(k)}
  end

  def add_targets t
    return t
  end

  def add_edges t
    @edges = build_edges t
  end
end
  
