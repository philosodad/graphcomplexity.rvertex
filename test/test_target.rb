$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'target'
require 'netgen_tgt'
require 'globals'

class TestTarget < Test::Unit::TestCase
  def setup
    Globals.new()
  end

  def test_init
    t = Target.new(5,3)
    assert t.x == 5, "t.x is not 5"
    assert t.y == 3, "t.y is not 3"
  end

  def test_target_graph
    g = TargetGraph.new(100, 20)
    assert g.nodes.length == 100, "wrong number of nodes"
    assert g.targets.length == 20, "wrong number of targets"
    assert $sensor_range == 500, "global set incorrectly"
    (0...(g.nodes.length - 1)).each do |k|
      assert g.nodes[k].x <= g.nodes[k+1].x, "nodes not in order"
    end
    assert g.edges.length > 0, "no edges"
  end
end
