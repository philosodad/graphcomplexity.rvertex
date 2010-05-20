$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'
require 'netgen'

class TestSim < Test::Unit::TestCase
  def setup
    @sn10 = SetNode.new(0)
    @sn11 = SetNode.new(1)
    @sn12 = SetNode.new(2)
    @sn13 = SetNode.new(3)
    @sn14 = SetNode.new(4)
    @sn15 = SetNode.new(5)
    @sn10.weight = 100
    @sn11.weight = 45
    @sn12.weight = 45
    @sn13.weight = 50
    @sn14.weight = 100
    snodes2 = [@sn10, @sn11, @sn12, @sn13, @sn14, @sn15]
    edges = Set.new([Set[0,1],Set[0,2],Set[0,3],Set[1,4], Set[1,3], Set[2,3], Set[2,4]])
    g = SetGraph.new(snodes2, edges)
    @sg = SetSimulator.new(g)
    @udg = UDGSimulator.new(80, 1000, 120)
 #   @rg = RandomSimulator.new(50, @udg.rg.edges.length)
    @rg = RandomSimulator.new(15, 70)
    @gg = GridSimulator.new(20,2)
    @rg.set
    @sg.set
#    @rg.rg.nodes.each{|k| puts k.covers.inspect}
    puts "initialized"
  end

  def test_gg
    a = @gg.getOnWeight
    @gg.set
    @gg.set_covers
    assert @gg.sim < 500
    b = @gg.getOnWeight
    assert_not_equal a,b
  end

  def test_udg
#    @udg.set
#    @udg.set_covers
#    assert @udg.sim < 500
  end

  def test_randomsim
    @rg.set_covers
    assert @rg.sim < 500
#    @rg.rg.nodes.each{|k| puts k.covers.inspect}
  end

  def test_setsim
    @sg.set_covers
    assert @sg.sim < 500
#    [@sn11,@sn12,@sn13].each{|k| assert_equal k.on, true}
#    [@sn10, @sn14].each{|k| assert_equal k.on, false}
  end

  def teardown
    @rg = nil
    @sg = nil
    @gg = nil
    @udg = nil
  end
end
