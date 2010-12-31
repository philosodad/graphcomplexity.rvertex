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
    g = TargetGraph.new(1000, 200)
    assert g.nodes.length == 1000, "wrong number of nodes"
    assert $sensor_range == 500, "global set incorrectly"
    assert g.edges.length > 0, "no edges"
    assert g.edges.kind_of?(Set), "edges are a #{g.class}"
    g.edges.each do |k|
      assert k.length > 0, "no nodes"
      assert k.kind_of?(Set), "that's a #{k.class}"
      k.each do |j|
        assert j.kind_of?(Fixnum), "that's a #{j.class}"
      end
    end
    assert g.edges.length == 200, "not enough targets"
    g.nodes.each do |k|
      assert k.kind_of?(BasicNode), "the node is a #{k.class}"
      k.neighbors.each do |j|
        pair = Set[k.id, j.id]
        b = false
        g.edges.each do |i|
          if pair.subset? i then
            b = true
            break
          end
        end
        assert b, "that pair is not in an edge!"
      end
    end
    g.edges.each do |k|
      g.nodes.each do |j|
        if k.include? j.id
          assert j.edges.include?(k)
        end
      end
    end
    g.nodes.each do |k|
      k.edges.each do |j|
        assert j.include?(k.id), "that edge does not contain me!"
      end
      k.neighbors.each do |j|
        b = false
        k.edges.each do |i|
          if i.include?(j.id)
            b = true
            break
          end
        end
        assert b, "that neighbor is not in an edge!"
      end
    end
        
  end

end
