require 'netgen'
require 'target'

class TargetGraph < SimpleGraph
  include PlanarMath
  attr_reader :targets
  def initialize(n, t)
    super()
    @targets = []
    add_nodes(n)
    add_targets(t)
    set_edges
  end

  def add_nodes n
    n.times do
      @nodes.push(get_node_type.new(rand($space), rand($space)))
    end
  end

  def get_node_type
    return Object.const_get('SimpleNode')
  end

  def add_targets t
    t.times do
      @targets.push(Target.new(rand($space), rand($space)))
    end
  end

  def set_edges
    @nodes = @nodes.sort_by{|k| k.x}
    @targets = @targets.sort_by{|k| k.x}
  end
end
