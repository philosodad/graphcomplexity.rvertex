$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'
require 'set'
require 'weighted_edge'

class TestWeightedEdge < Test::Unit::TestCase
  def setup
    @we0 = WeightedEdge.new(Set[1,1])
    @we1 = WeightedEdge.new(Set[1,3])
    @we2 = WeightedEdge.new(Set[2,2])
    @we0.neighbors = [@we1, @we2]
    @we1.neighbors = [@we0, @we2]
    @we2.neighbors = [@we0, @we1]
  end

  def test_init
    assert_equal @we0.uv, Set[1,2]
    assert_equal @we0.weight, nil
  end

  def test_setedges
    @we1.set_edges
    @we1.edges.each{|k| assert k.weight == nil}
    assert_equal [Set[@we1.id, @we2.id], Set[@we0.id, @we1.id]] - @we1.edges.to_a.collect{|k| k.uv}, []
  end
end
