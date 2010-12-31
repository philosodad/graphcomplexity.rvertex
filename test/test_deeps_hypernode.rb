$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'edge_eep'
require 'globals'
require 'node_eep_hyper'
require 'netgen_tgt'

class TestHyperNode < Test::Unit::TestCase
  def setup
    Globals.new 15,34,2,12,20
    @s0 = DeepsHyperNode.new(4,6)
    @s1 = DeepsHyperNode.new(9,11)
    @s2 = DeepsHyperNode.new(10,6)
    @s3 = DeepsHyperNode.new(11,9)
    @s4 = DeepsHyperNode.new(12,17)
    @s5 = DeepsHyperNode.new(15,11)
    @s6 = DeepsHyperNode.new(18,8)
    @t1 = Target.new(6,8)
    @t2 = Target.new(8,16)
    @t3 = Target.new(12,14)
    @t4 = Target.new(15,6)
    @s0.weight = 60
    @s1.weight = 70
    @s2.weight = 50
    @s3.weight = 70
    @s4.weight = 60
    @s5.weight = 50
    @s6.weight = 80
    @n = [@s1, @s2, @s3, @s4, @s5, @s6, @s0]
    @t = [@t1, @t2, @t3, @t4]
  end

  def test_setgraph
    g = SetTargetGraph.new(@n, @t)
    assert g.nodes.length == 7, "not enough nodes"
    assert g.edges.length == 4, "not enough targets?"
    assert @s1.neighbors.include?(@s5), "s1 should neighbor s5"
    assert !@s1.neighbors.include?(@s6), "s1 should not neighbor s6"
    assert @s2.edges.length == 2, "s2 has wrong number of edges"
  end

  def test_hypernodes
    g = SetTargetGraph.new(@n, @t)
    g.nodes.each{|k| k.set_edges}
    @s1.edges.each{|k| p k.supply}
  end

end
