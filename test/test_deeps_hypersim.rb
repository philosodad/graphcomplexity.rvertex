$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'globals'
require 'node_eep_hyper'
require 'netgen_eep_hyper'

class TestHyperSim < Test::Unit::TestCase
  def setup
    Globals.new 15,15,2,22, 40
    @tg = TargetGraph.new 15, 5
  end

  def test_graph_setup
    g = DeepsHyperGraph.new(25,10)
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
end
