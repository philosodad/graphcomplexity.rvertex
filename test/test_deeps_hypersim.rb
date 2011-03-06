$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'globals'
require 'node_eep_hyper'
require 'netgen_eep_hyper'
require 'sim'

class TestHyperSim < Test::Unit::TestCase
  def setup
    Globals.new 15,15,2,22, 40
    @tg = TargetGraph.new 15, 5
  end

  def test_tg
    assert_equal @tg.nodes.length, 15
    assert @tg.edges.collect{|k| k.cover.length}.reduce(:+) >= 15, 'some nodes not assigned to targets'
  end

  def test_graph_setup
    g = DeepsHyperGraph.new(25,10)
    assert g.connect?
    assert g.coverable?
    assert_raise TypeError do DeepsHyperGraph.new(RandomGraph.new(45,45)) end
    assert_nothing_raised do DeepsHyperGraph.new(@tg) end
    d = DeepsHyperGraph.new(@tg)
    assert d.nodes.collect{|k| k.id} - @tg.nodes.collect{|k| k.id} == [], "ids not the same"
    assert d.nodes.collect{|k| k.id} - g.nodes.collect{|k| k.id} == d.nodes.collect{|k| k.id}, "ids not disjoint"
    assert_not_equal d.nodes.collect{|k| k.id} - g.nodes.collect{|k| k.id}, [] #just making sure
    assert d.coverable?, "d cannot be covered"
    failtrack = false
    num = 0
    until failtrack == true 
      begin
        u = DeepsHyperGraph.new(TargetGraph.new(3, 6))
        u.nodes.each{|k| assert k.weight > 0, "weight of 0"}
        u.edges.each{|k| p k}
        u.edges.each{|k| assert !k.empty?, "empty edge"}
        assert u.coverable?, "u cannot be covered"
        failtrack = true
      rescue ArgumentError => ex
        puts "#{ex.class}:#{ex.message}"
        failtrack = true
      rescue StandardError => ex
        num += 1
        puts "#{num} - #{ex.class}:#{ex.message}"
        failtrack = false
      end
    end
    assert_raise ArgumentError do DeepsHyperGraph.new(TargetGraph.new(3,7)) end
  end

  def test_hypersim
    g = DeepsHyperGraph.new(@tg)
    s1 = DeepsHyperSimulator.new(g)
    s2 = DeepsHyperRunningSimulator.new(g)
    s3 = DeepsHyperSteppingSimulator.new(g)
    h = DeepsHyperGraph.new(@tg)
    assert @tg.edges.any?, 'tg is edge free'
    assert @tg.nodes.select{|k| k.neighbors.any?}.any?, 'tg has no neighbors'
    assert @tg.nodes.select{|k| k.edges.any?}.any?, 'no tg node has an edge'
    @tg.nodes.each{|k| assert k.edges.any?, 'tg has an edge free node'}
    assert s1.rg.coverable?, 's1 cannot be covered'
    h.nodes.each{|k| k.set_edges}
    assert h.nodes.select{|k| k.neighbors.any?}.any?, 'this graph has no neighbors'
    assert h.nodes.select{|k| k.edges.any?}.any?, 'this graph is edge free'
    h.nodes.each{|k| assert k.edges.any?, 'this node has no edges'}
    [s1, s2, s3].each{|k| k.set}
    [s1, s2, s3].each{|k| assert k.rg.connect?, 'graph not connectable'}
    assert s1.rg.nodes.select{|k| k.edges.any?}.any?, 'no node has any edges'
    s1.rg.nodes.each{|k| assert k.edges.any?, 'this node has no edges'}
    p s1.sim
    p s2.long_sim
    p s3.long_sim
    [s2, s3].each{|k| assert !k.rg.coverable?, 'long sims coverable'}
    [s2, s3].each{|k| assert !k.rg.covered?, 'long sims covered'}
  end
end
