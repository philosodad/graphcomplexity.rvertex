$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'
require 'netgen'

class TestModSim < Test::Unit::TestCase
  def setup
    @gg = GridSimulator.new(16,2)
    @mg = MatchSimulator.new(@gg.rg)
    @xg = MatchMaxSimulator.new(@gg.rg)
    @wg = MatchMWMSimulator.new(@gg.rg)
  end

  def test_init
    @gg.rg.nodes.each{|k| assert k.neighbors.length > 1}
    @mg.rg.nodes.each{|k| assert k.neighbors.length > 1}
    @wg.rg.nodes.each{|k| assert k.neighbors.length > 1}
  end

  def test_set
    @gg.set
    @mg.set
    @wg.set
    @gg.rg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}
    @mg.rg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}    
    @wg.rg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}
  end

  def test_sim
    @gg.set
    @mg.set
    @xg.set
    @wg.set
    @gg.set_covers
    @gg.rg.nodes.each{|k| assert_not_nil k}
    @gg.rg.nodes.each{|k| assert_equal k.class, Node}
    puts "sim mg"
    assert @mg.sim < 500,  "matchsim didn't terminate"
    puts "sim gg"
    assert @gg.sim < 500, "sim didn't terminate"
    puts "sim xg"
    assert @xg.sim < 500, "xsim didn't terminate"
    puts "sim wg"
    assert @wg.sim < 500, "wsim didn't terminate"
    assert @mg.rg.covered?, "matchgrid not covered"
    assert @gg.rg.covered?, "auto didn't cover"
#    assert @xg.rg.covered?, "xg didn't cover"
    assert @wg.rg.covered?, "wg didn't cover"
    puts "gg:#{@gg.get_on_weight}, mg:#{@mg.get_on_weight}, wg:#{@wg.get_on_weight}, tw:#{@gg.get_total_weight}"
  end

  def teardown
    @gg = nil
    @mg = nil
    @xg = nil
    @wg = nil
  end
end
