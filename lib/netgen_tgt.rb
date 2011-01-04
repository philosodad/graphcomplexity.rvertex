require 'netgen'

class TargetGraph < SimpleGraph
  include PlanarMath
  include Targetable
  include Neighborly

  def initialize *args
    if args.length == 2
      n = args[0]
      t = args[1]
      raise ArgumentError, "#{t} must be less than #{n}!" unless args[1] <= (1..n).inject(:*)
      super()
      add_nodes(n)
      add_edges t
      set_neighbors
      set_edges
    end
    if args.length == 1
      raise TypeError, "g must be kind of TargetGraph" unless args[0].kind_of?(TargetGraph)
      g = args[0]
      super()
      g.nodes.each{|k| add_single_node(k)}
      @edges = g.edges
    end
      
  end

  def add_nodes n
    n.times do
      @nodes.push(get_node_type.new(rand($space), rand($space)))
    end
  end

  def add_single_node n
    @nodes.push(get_node_type.new(n))
  end

  def get_node_type
    return Object.const_get('HyperNode')
  end

  def set_edges
    @edges.each do |k|
      @nodes.each do |j|
        if k.include? j.id then
          j.edges.add(k)
        end
      end
    end
  end

  def add_targets t
    targets = []
    t.times do
      targets.push(Target.new(rand($space), rand($space)))
    end
    return targets
  end

  def add_edges t
    @edges = build_edges t 
    attempts = 0
    while @edges == nil or @edges.length < t
      raise StandardError, "Target requirement unfulfilled" unless attempts < $space**2
      @edges += build_edges 1
      attempts += 1
    end
  end
  
  def build_edges t
    eggs = Set[]
    targets = add_targets t
    exis = add_from_to_by @nodes, targets, 'x'
    whys = add_from_to_by @nodes, targets, 'y'
    targets.each do |k|
      eds = (exis[k]&whys[k])
      eggs.add( eds.select{|j| planar_distance(j, k) <= $sensor_range}.collect{|k| k.id}.to_set)
    end
    return eggs - Set[Set[]]
    nil
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
  
