$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'globals'
require 'node_eep_hyper'
require 'netgen_eep_hyper'
require 'sim'

class TestHyperSim < Test::Unit::TestCase
  def setup
    puts "setup\n++++++\n"
    Globals.new 15,15,2,22, 40
    @tg = TargetGraph.new 15, 5
  end

  def test_tg
    puts "test tg\n+++++\n"
    assert_equal @tg.nodes.length, 15
    assert @tg.edges.select{|k| k.cover.empty?}.empty?, 'some target has no assigned nodes'
    assert @tg.edges.collect{|k| k.cover.length}.reduce(:+) >= 15, 'some nodes not assigned to targets'
  end

  def test_graph_setup
    puts "test setup\n+++++\n"
    g = DeepsHyperGraph.new(25,10)
    assert g.connect?, "g not connected"
    g.nodes.each{|k| k.set_edges}
    assert g.coverable?, "g not coverable"
    assert_raise TypeError do DeepsHyperGraph.new(RandomGraph.new(45,45)) end
    assert_nothing_raised do DeepsHyperGraph.new(@tg) end
    d = DeepsHyperGraph.new(@tg)
    assert d.nodes.collect{|k| k.id} - @tg.nodes.collect{|k| k.id} == [], "ids not the same"
    assert d.nodes.collect{|k| k.id} - g.nodes.collect{|k| k.id} == d.nodes.collect{|k| k.id}, "ids not disjoint"
    assert_not_equal d.nodes.collect{|k| k.id} - g.nodes.collect{|k| k.id}, [] #just making sure
    #assert d.coverable?, "d cannot be covered"
    failtrack = false
    num = 0
    #until failtrack == true 
    #  begin
    #    u = DeepsHyperGraph.new(TargetGraph.new(3, 6))
    #    u.nodes.each{|k| assert k.weight > 0, "weight of 0"}
    #    u.edges.each{|k| p k}
    #    u.edges.each{|k| assert !k.empty?, "empty edge"}
    #    assert u.coverable?, "u cannot be covered"
    #    failtrack = true
    #  rescue ArgumentError => ex
    #    puts "#{ex.class}:#{ex.message}"
    #    failtrack = true
    #  rescue StandardError => ex
    #    num += 1
    #    puts "#{num} - #{ex.class}:#{ex.message}"
    #    failtrack = false
    #  end
    #end
    assert_raise ArgumentError do DeepsHyperGraph.new(TargetGraph.new(3,7)) end
  end

  def test_hypersim
    puts "test hypersim\n+++++\n"
    g = DeepsHyperGraph.new(@tg)
    s1 = DeepsHyperSimulator.new(g)
    s2 = DeepsHyperRunningSimulator.new(g)
    s3 = DeepsHyperSteppingSimulator.new(g)
    h = DeepsHyperGraph.new(@tg)
    assert @tg.edges.any?, 'tg is edge free'
    assert @tg.nodes.select{|k| k.neighbors.any?}.any?, 'tg has no neighbors'
    assert @tg.nodes.select{|k| k.edges.any?}.any?, 'no tg node has an edge'
    @tg.nodes.each{|k| assert k.edges.any?, 'tg has an edge free node'}
    #assert s1.rg.coverable?, 's1 cannot be covered'
    h.nodes.each{|k| k.set_edges}
    assert h.nodes.select{|k| k.neighbors.any?}.any?, 'this graph has no neighbors'
    assert h.nodes.select{|k| k.edges.any?}.any?, 'this graph is edge free'
    h.nodes.each{|k| assert k.edges.any?, 'this node has no edges'}
    [s1, s2, s3].each{|k| k.set}
    [s1, s2, s3].each{|k| assert k.rg.connect?, 'graph not connectable'}
    assert s1.rg.nodes.select{|k| k.edges.any?}.any?, 'no node has any edges'
    s1.rg.nodes.each{|k| assert k.edges.any?, 'this node has no edges'}
    s1.sim
    assert s1.rg.covered?, "sim not covered"
    s2.long_sim
    s3.long_sim
    [s3, s2].each{|k| assert !k.rg.coverable?, "long sims #{k} coverable"}
    [s2, s3].each{|k| assert !k.rg.covered?, 'long sims covered'}
    s2.rg.nodes.each{|k| assert Set.new(k.charges).subset?(k.edges)}
    s2.rg.nodes.each{|k| assert Set.new(k.charges + k.neighbors.collect{|j| j.charges}).subset?(k.edges + Set.new(k.neighbors.collect{|j| j.edges}))}
    s2.rg.nodes.each{|k| assert k.edges.subset?(Set[k.neighbors.collect{|j| j.charges} + k.charges]), "s2-orphaned edge: #{(k.edges - [k.neighbors.collect{|j| j.charges + k.charges}]).length}, #{k.edges.collect{|j| j.type}}, #{k.charges.length}, #{k.neighbors.collect{|j| j.charges}.length}"}
  end

  def test_failure_run
    puts "test run_fail\n+++++\n"
    f = false
    count = 0
    until f or count == 50
      s1 = nil
      s1 = DeepsHyperRunningSimulator.new(DeepsHyperGraph.new(TargetGraph.new(15,5)))
      s1.set
      s1.long_sim
      f = true if s1.rg.coverable?
      count +=1
    end
    s1.rg.print_out if f
    if f then
      s1.rg.nodes.each{|k| assert k.charges_covered?, "run: all_done: #{s1.all_done}, #{k.id}, #{k.on == nil ? 'nil' : k.on}, #{k.now}, #{k.next}, charge not covered."}
    end
    assert_equal s1.rg.coverable?, f, "printed an uncoverable graph"
    assert !f, "printed a coverable graph"
  end

  def test_failure_step
    puts "test run_step\n+++++\n"
    f = false
    count = 0
    until f or count == 50
      s1 = nil
      s1 = DeepsHyperSteppingSimulator.new(DeepsHyperGraph.new(TargetGraph.new(15,5)))
      s1.set
      s1.long_sim
      f = true if s1.rg.coverable?
      count +=1
    end
    s1.rg.print_out if f
    if f then
      s1.rg.nodes.each{|k| assert k.charges_covered?, "step: all_done: #{s1.all_done}, #{k.id}, #{k.on == nil ? 'nil' : k.on}, #{k.now}, #{k.next}, charge not covered."}
      s1.rg.nodes.each{|k| assert (k.edges - [k.neighbors.collect{|j| j.charges} + k.charges]).empty?, "orphaned edge"}
    end
    assert_equal s1.rg.coverable?, f, "printed an uncoverable graph"
    assert !f, "printed a coverable graph"
  end

  def teardown
    @tg.nodes.each{|k| k = nil}
    @tg.edges.each{|k| k = nil}
    @tg = nil
  end
end
