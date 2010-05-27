$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'
require 'netgen'

class TestModSim < Test::Unit::TestCase
  def setup
    @gg = GridSimulator.new(16,2)
    @mg = MatchSimulator.new(@gg.rg)
    @xg = MatchMaxSimulator.new(@gg.rg)
  end

  def test_init
    @gg.rg.nodes.each{|k| assert k.neighbors.length > 1}
    @mg.rg.nodes.each{|k| assert k.neighbors.length > 1}
  end

  def test_set
    @gg.set
    @mg.set
    @gg.rg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}
    @mg.rg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}
  end

  def test_sim
    @gg.set
    @mg.set
    @xg.set
    @gg.set_covers
    @gg.rg.nodes.each{|k| assert_not_nil k}
    @gg.rg.nodes.each{|k| assert_equal k.class, Node}
    assert @mg.sim < 500,  "matchsim didn't terminate"
    assert @gg.sim < 500, "sim didn't terminate"
    assert @xg.sim < 500, "xsim didn't terminate"
    assert @mg.rg.covered?, "matchgrid not covered"
    assert @gg.rg.covered?, "auto didn't cover"
    assert @xg.rg.covered?, "xg didn't cover"
    puts "gg:#{@gg.get_on_weight}, mg:#{@mg.get_on_weight}, tw:#{@gg.get_total_weight}"
  end

  def teardown
    @gg = nil
    @mg = nil
  end
end
