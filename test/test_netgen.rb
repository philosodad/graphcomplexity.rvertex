$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'netgen'
require 'node'

class TestGraphs < Test::Unit::TestCase

  def setup #always required for a test case
    @n0 = SetNode.new(0)
    @n1 = SetNode.new(1)
    @n2 = SetNode.new(2)
    @n0.weight = 3
    @n1.weight = 1
    @n2.weight = 3
    e1 = Set.new([0,1])
    e2 = Set.new([1,2])
    edges = Set.new([e1,e2])
    @sg = SetGraph.new([@n0, @n1, @n2], edges)
    @sg.nodes.each{|k| k.boot}
    @sg.nodes.each{|k| k.boot}
  end

  def test_UDG
    @udg = UnitDiskGraph.new(50, 500, 1000)
    assert @udg.nodes.length == 50
    assert @udg.edges.length == 25*49
    @udg.edges.each{|k| assert k.length == 2}
    @udg.nodes.each{|k| k.set_edges}
    @udg.nodes.each{|k| assert k.neighbors.length == 49}
    @udg.nodes.each{|k| assert k.neighbors.length == k.edges.length}
  end
  
  def test_SG
    assert_equal @n1.id, 1
    assert @sg.nodes.length == 3
    assert @sg.edges.length == 2
    @sg.edges.each{|k| assert k.length == 2}
    @sg.edges.each{|k| assert k.include?(@n1.id)}
    assert_equal @n1.neighbors.length, 2
    assert_equal @n0.neighbors.length, 1
    assert_equal @n2.neighbors.length, 1
    @sg.nodes.each{|k| assert_equal k.on, nil}
    assert_equal @n1.covers.class, LdGraph
    assert_equal @n1.covers.ldnodes[0].class, LdNode
    assert_equal @n1.covers.ldnodes.class, Array
    @sg.nodes.each{|k| k.covers.ldnodes.each{|j| assert_equal j.class, LdNode}}
    @sg.nodes.each{|k| assert_equal k.covers.ldnodes.length, 2}
  end
end
