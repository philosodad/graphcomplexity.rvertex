$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'
require 'set'

class TestSimplenode < Test::Unit::TestCase

  def setup #always required for a test case
    @sn10 = TotalWeightNode.new(10,10)
    @sn11 = TotalWeightNode.new(10,11)
    @sn12 = TotalWeightNode.new(10,12)
    @sn13 = TotalWeightNode.new(10,13)
    @sn14 = TotalWeightNode.new(10,14)
    @sn15 = TotalWeightNode.new(10,15)
    @sn10.neighbors = [@sn11, @sn12, @sn13]
    @sn11.neighbors = [@sn14, @sn13, @sn10]
    @sn12.neighbors = [@sn10, @sn13, @sn14]
    @sn13.neighbors = [@sn10, @sn11, @sn12]
    @sn14.neighbors = [@sn11, @sn12]
    @sn10.weight = 100
    @sn11.weight = 45
    @sn12.weight = 45
    @sn13.weight = 50
    @sn14.weight = 100
    @snodes2 = [@sn10, @sn11, @sn12, @sn13, @sn14]
    @snodes2.each{|k| k.set_edges}
    @snodes2.each{|k| k.set_covers}
  end
  
  def test_init
    @snodes2.each{|k| assert_equal k.currentcover, 0}
  end

  def test_buildcovers
    @snodes2.each{|k| k.covers.ldnodes.each{|j| assert_not_nil j.cover}}
    assert_equal @sn10.covers.ldnodes[0].totalweight, 140
    assert_equal @sn14.covers.ldnodes[0].totalweight, 90
  end

  def teardown
    @sn12.covers.ldnodes[0].zero_out
    @sn12.zero_out
    @snodes2.each{|k| k = nil}
    @snodes2 = nil
  end
  
end
