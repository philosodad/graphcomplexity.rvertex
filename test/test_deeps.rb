$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'

class TestDeeps < Test::Unit::TestCase
  def test_deeps
    puts "test deeps"
    dpsim = DeepsSimulator.new(RandomGraph.new(40,5))
    desim = DeepsSimulator.new(RandomGraph.new(40,5))
    dpsim.set
    dpsim.rg.nodes.each do |k|
      assert k.neighbors.length > 0, 'this node has no neighbors'
      k.edges.select{|e| e.uv.include?(843)}
      assert k.edges.length > 0, 'this node has no edges'
      k.edges.each do |j|
        assert j.class == DeepsEdge, 'That aint a DeepsEdge'
        assert j.uv.class == Set, 'That aint a set'
        assert j.uv.length == 2, 'That set is two long'
        assert !j.uv.include?(1.2), 'why does my set of integers have a real?'
        if j.uv.include?(900) then puts "j includes 900" end
        assert j.u == k, 'edge.u incorrect'
        assert k.neighbors.include?(j.v), 'edge.v incorrect'
        assert j.v.edges.include?(j), 'these edges are not equal'
      end
      assert k.onlist.length == 0, 'onlist.length == #{k.onlist.length}'
        
    end
    dpsim.rg.nodes.each{|k| k.do_next}
    dpsim.rg.nodes.each do |k| 
      m = k.next
      s = 'k.next is ' + k.next
      assert (k.next == :poor), s
    end
    dpsim.rg.nodes.each{|k| k.do_next}
    dpsim.rg.nodes.each{|k| k.do_next}
    c = 0
    dpsim.rg.nodes.each do |k|
      assert k.poorest != nil, 'this node has no poorest edge'
      assert k.poorest.class == DeepsEdge
      assert k.poorest.u == k
      c += k.charges.length
#      assert k.onlist == {}, 'onlist is not an empty dict!'
      assert k.onlist == [], 'onlist is not an empty array!'
    end
    assert c != 0, 'nothing is in charge of anything'
    puts "total #{dpsim.rg.nodes.length}, charged #{c}"
    d = c
    e = 0
    dpsim.rg.nodes.each{|k| k.edges.each do |j| 
        assert_not_nil j.v.poorest
        assert j.v.poorest.type == :sink, 'poorest is not a sink'
      end
    }
    dpsim.rg.nodes.each{|k| assert k.next == :hills, 'next not sinks'}
    dpsim.rg.nodes.each{|k| k.do_next}
    dpsim.rg.nodes.each do |k|
      k.edges.select{|j| j.type == :sink}.each do |l|
        assert (k.charges.include?(l) or l.v.charges.collect{|m| m.uv}.include?(l.uv)), 'no node is in charge of this sink'
        assert !(k.charges.include?(l) and l.v.charges.collect{|m| m.uv}.include?(l.uv)), 'two nodes are in charge of this sink!'
      end
    end
    dpsim.rg.nodes.each{|k| k.do_next}
    dpsim.rg.nodes.each do |k|
      k.edges.each{|j| assert j.type != nil, 'that edge is nil!'}
      d += k.edges.select{|j| j.type == :hill}.length
    end
    assert d > c, 'sinks + hills should be greater than sinks'
    dpsim.rg.nodes.each do |k|
      k.edges.each do |j|
        assert (k.charges.include?(j) or j.v.charges.collect{|l| l.uv}.include?(j.uv)), 'no node is in charge of this edge!'
        assert !(k.charges.include?(j) and j.v.charges.collect{|l| l.uv}.include?(j.uv)), 'two nodes are in charge of this edge!'
      end
    end
    dpsim.rg.nodes.each{|k| e+= k.charges.length}
    puts e
    puts "all charges: #{e}, sinks+hills: #{d}, all_edges: #{dpsim.rg.edges.length}"
    puts "total #{dpsim.rg.nodes.length}, charged #{d}"
    e = d
    dpsim.rg.nodes.each{|k| e *= k.charges.length}
    assert_equal e, 0
    dpsim.rg.nodes.each{|k| assert k.next == :analyze, 'state is not analyze'}
    dpsim.rg.nodes.each{|k| assert k.onlist == [], 'onlist changed'}
    dpsim.rg.nodes.each{|k| k.set_next (:boot)}
    assert dpsim.sim < 500, "deeps running past 500"
    assert dpsim.rg.covered?, 'deeps not covering'
    dpsim.rg.reduce_by_min
    c = 0
    desim.set
    12.times.do
    desim.rg.reduce_by_min
    desim.rg.nodes.each do |k|
      assert k.next == :boot, 'not ready to boot'
      assert k.neighbors.length > 0, 'no neighbors'
      assert k.neighbors.length == k.edges.length, 'no edges'
    end
    assert desim.sim < 500, 'other deeps overruns'
  end
end
