$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
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
    @s2.weight = 60
    @s3.weight = 70
    @s4.weight = 60
    @s5.weight = 90
    @s6.weight = 50
    @n = [@s0, @s1, @s2, @s3, @s4, @s5, @s6]
    @t = [@t1, @t2, @t3, @t4]
  end

  def test_setgraph
    assert @s0.id ==0, "s0 id is #{@s0.id}"
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
    assert g.nodes.select{|k| k.edges.any?}.any?, "nodes have no edges"
    assert_equal @s1.edges.collect{|k| k.supply}.reduce(:+), 680, "s1 edges wrong supplys"
    @s4.weight = 30
    assert @s1.edges.collect{|k| k.supply}.reduce(:+) < 630, "s1 supply didn't change"
  end

  def test_donext
    g = SetTargetGraph.new(@n, @t)
    g.nodes.each{|k| k.set_edges}
    g.nodes.each{|k| k.do_next}
    g.nodes.each{|k| assert k.poorest == nil, "poorest is not nil"}
    g.nodes.each{|k| k.do_next}
    g.nodes.each{|k| assert k.poorest != nil, "#{k.id} poorest is nil"}
    g.nodes.each{|k| k.do_next}
    assert @s1.charges.length == 1, "s1 has #{@s1.charges.length} charges"
    assert @s1.charges.include?(@s1.poorest), "s1's poorest is #{@s1.poorest.ids}"
    assert @s4.charges.length == 0, "s4 has a charge"
    assert @s4.poorest == @s1.poorest, "s1 poorest is not s4 poorest"
    assert @s5.charges.length == 1, "s5 has no charge"
    untypededge = false
    g.nodes.each{|k| k.edges.each{|j| if j.type == nil then untypededge = true end}}
    assert untypededge, "no untyped edge!"
    g.nodes.each{|k| k.do_next}
    g.nodes.each{|k| k.edges.each{|j| assert j.type != nil}}
    assert_equal g.nodes.collect{|k| k.edges.to_a}.flatten.select{|j| j.type == :hill}.length, 4
    g.nodes.each{|k| k.do_next}
    assert @s5.charges.length == 2, "s5 has #{@s5.charges.length}"
    g.nodes.each{|k| k.set_now :analyze}
    @s4.on = false
    g.nodes.each{|k| k.send_status}
    assert @s1.sole_survivor?, "s1 is not the sole survivor!"
    assert !@s5.sole_survivor?, "s5 is a sole survivor"
    @s0.on = true
    assert !@s1.charges_covered?, "s1 charges covered"
    @s4.on = true
    assert @s1.charges_covered?, "s1 charges not covered"
    @s0.on = false
    assert @s1.charges_covered?, "s1 charges not covered"
  end

  def teardown
    @s1.zero_out
    @t1.zero_out
    @n.each{|k| k = nil}
    @t.each{|k| k = nil}
    @n = nil
    @t = nil
  end
end
