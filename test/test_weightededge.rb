$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'
require 'set'
require 'weighted_edge'

class TestWeightedEdge < Test::Unit::TestCase
  def setup
    @we0 = WeightedEdge.new(Set[1,0])
    @we1 = WeightedEdge.new(Set[1,3])
    @we2 = WeightedEdge.new(Set[2,2])
    @ce1 = ColoredEdge.new(Set[1,2])
  end

  def test_init
    assert_equal @we0.uv, Set[1,0]
    assert_equal @we0.weight, nil
    assert_equal @ce1.criteria, nil
    @ce1.color = :blue
    assert_not_equal @ce1.criteria, nil
    @we1.weight = 300
    assert_equal @we1.criteria, 300, "criteria did not take"
  end

end
