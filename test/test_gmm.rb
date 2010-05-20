$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'
require 'set'

class TestGMM < Test::Unit::TestCase
  def setup
    @n0 = Node.new(0,1)
    @mn0 = MatchNode.new(@n0)
    @mn1 = MatchNode.new(0,2)
    @mn2 = MatchNode.new(1,1)
    @mn0.neighbors = [@mn1, @mn2]
    @mn1.neighbors = [@mn0, @mn2]
    @mn2.neighbors = [@mn0, @mn1]
  end

  def test_init
    assert_equal @mn0.x, @n0.x
    assert_equal @mn0.y, @n0.y
    assert_equal @mn0.weight, @n0.weight
  end
  
  def test_setedges
    @mn1.set_edges
    @mn1.edges.each{|k| assert_equal k.class, WeightedEdge}
    assert_equal [Set[@mn1.id, @mn2.id], Set[@mn0.id, @mn1.id]] - @mn1.edges.to_a.collect{|k| k.uv}, []
  end

  def test_chooseedge
    @mn0.set_edges
    assert_equal @mn0.choose_edge.class, WeightedEdge
    @mn0.edges.each{|k| k.weight = 4}
    assert_equal @mn0.choose_edge, :empty
  end

end
