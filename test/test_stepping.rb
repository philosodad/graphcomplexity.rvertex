$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'
require 'set'

class TestStepping < Test::Unit::TestCase

  def setup
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
    @snedges = Set[Set[10,11], Set[10,12], Set[10,13], Set[11,13],Set[11,14], Set[12,13], Set[12,14]]
    @g = SetGraph.new(@snodes2, @snedges)
    @s = SetSimulator.new(@g)
    @m = MatchSimulator.new(@g)
  end
  
  def test_simsteps
    @s.set
    @s.set_covers
    @s.long_sim
    [@sn10, @sn11].each{|k| assert_equal k.weight, 0}
    assert_equal @sn12.weight, 5
    assert_equal @sn13.weight, 20
    @m.set
    @m.long_sim
    assert_equal @m.rg.nodes.select{|k| k.weight == 0}.length, 1
  end
end
