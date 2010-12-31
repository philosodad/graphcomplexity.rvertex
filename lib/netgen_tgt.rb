require 'netgen'

class TargetGraph < SimpleGraph
  include PlanarMath
  include Targetable
  include Neighborly

  def initialize(n, t)
    super()
    add_nodes(n)
    add_edges t
    set_neighbors
    set_edges
  end

  def add_nodes n
    n.times do
      @nodes.push(get_node_type.new(rand($space), rand($space)))
    end
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
    while @edges.length < t
      @edges += build_edges 1
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
    return eggs
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
  
