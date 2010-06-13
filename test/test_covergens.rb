$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'netgen'
require 'set'

class TestCoverGens < Test::Unit::TestCase

  def setup
    @sn10 = SetNode.new(10)
    @sn11 = SetNode.new(11)
    @sn12 = SetNode.new(12)
    @sn13 = SetNode.new(13)
    @sn14 = SetNode.new(14)
    @sn15 = SetNode.new(15)
    @sn10.weight = 5
    @sn11.weight = 15
    @sn12.weight = 20
    @sn13.weight = 30
    @sn14.weight = 10
    @snodes = [@sn10, @sn11, @sn12, @sn13, @sn14]
    @snedge = Set[Set[10,11], Set[10,12], Set[10,13], Set[11,13],Set[11,14], Set[12,13], Set[12,14]]
    @on10 = SetNodeObs.new(10)
    @on11 = SetNodeObs.new(11)
    @on12 = SetNodeObs.new(12)
    @on13 = SetNodeObs.new(13)
    @on14 = SetNodeObs.new(14)
    @on15 = SetNodeObs.new(15)
    @on10.weight = 5
    @on11.weight = 15
    @on12.weight = 20
    @on13.weight = 30
    @on14.weight = 10
    @onodes = [@on10, @on11, @on12, @on13, @on14]
    @sg = SetGraph.new(@snodes, @snedge)
    @og = SetGraph.new(@onodes, @snedge)
  end
  
  def test_init
    assert @sn10.neighbors.include?(@sn11)
    assert @on11.neighbors.include?(@on14)
    assert_not_equal @sg.nodes[0].class, @og.nodes[0].class
    assert_equal @sg.nodes[0].weight, @og.nodes[0].weight
  end

  def test_covers
    [@sg, @og].each{|k| k.set_edges}
    [@sg, @og].each{|k| k.nodes.each{|j| j.set_edges}}
    [@sg, @og].each{|k| k.nodes.each{|j| j.set_covers}}
    @snodes.each_index{|k| assert_equal @snodes[k].covers.ldnodes.length, @onodes[k].covers.ldnodes.length}
    @sn13.covers.ldnodes.each_index do |k|
      assert_equal @sn13.covers.ldnodes[k].cover, @on13.covers.ldnodes[k].cover
    end
    @sn13.covers.ldnodes.each{|k| p k.cover}
  end
  
  def teardown
    [@og, @sg].each{|j| j.nodes.each{|k| k = nil}}
    [@og, @sg].each{|k| k = nil}
  end

end
  
