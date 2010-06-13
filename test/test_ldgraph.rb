$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'ldgraph'
require 'node'

class TestLdGraph < Test::Unit::TestCase
  def setup
    @n0 = Node.new(4,5)
    @n1 = Node.new(3,4)
    @n2 = Node.new(2,3)
    @testset = Set[Set[0,2], Set[1], Set[0,1,2]]
    @n0.neighbors = [@n2]
    @n1.neighbors = [@n2]
    @n2.neighbors = [@n0, @n1]
    @sn10 = SetNode.new(10)
    @sn11 = SetNode.new(11)
    @sn12 = SetNode.new(12)
    @sn13 = SetNode.new(13)
    @sn14 = SetNode.new(14)
    @sn15 = SetNode.new(15)
    @sn10.neighbors = [@sn11, @sn12, @sn13]
    @sn11.neighbors = [@sn14, @sn13, @sn10]
    @sn12.neighbors = [@sn10, @sn13, @sn14]
    @sn13.neighbors = [@sn10, @sn11, @sn12]
    @sn14.neighbors = [@sn11, @sn12]
    @sn10.weight = 5
    @sn11.weight = 15
    @sn12.weight = 20
    @sn13.weight = 30
    @sn14.weight = 10
    @snodes2 = [@sn10, @sn11, @sn12, @sn13, @sn14]
  end

  def test_init
    @ld1 = LdGraph.new(@testset, [@n0, @n1, @n2])
    assert_equal @ld1.ldnodes.length, 2
    assert_kind_of @ld1.ldnodes[1], LdNode
    @ld1.ldnodes.each{|k| puts k.inspect}
    puts @ld1.edges.length
    assert @ld1.edges.length == 0
    puts @ld1.edges.inspect
    @ld1.ldnodes.each{|k| puts k.edges.inspect}
  end

  def test_burncover
    @snodes2.each{|k| k.set_edges}
    @snodes2.each{|k| k.set_covers}
    assert @sn10.id == 10
    p @sn11.covers
    @sn10.neighbors.each{|k| k.remove_neighbor(@sn10)}
    assert !@sn11.neighbors.include?(@sn10)
    assert @sn11.neighbors.include?(@sn13)
    @sn10.neighbors.each{|k| k.neighbors.each{|j| assert_not_nil j}}
    @sn10.neighbors.each{|k| k.burn_cover @sn10}
    p @sn11.covers
  end

  def teardown
    @n0.zero_out
    [@n0, @n1, @n2].each{|k| k = nil}
  end
end
