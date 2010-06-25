$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'
require 'netgen'
require 'node_star'
require 'sim'

class TestStar < Test::Unit::TestCase

  def setup #always required for a test case
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
    @sn10.weight = 100
    @sn11.weight = 45
    @sn12.weight = 45
    @sn13.weight = 50
    @sn14.weight = 100
    @snodes2 = [@sn10, @sn11, @sn12, @sn13, @sn14]
    @snedges = Set[Set[10,11],Set[10,12],Set[10,13],Set[11,13],Set[11,14],Set[12,13],Set[12,14]]
    @mg = SetGraph.new(@snodes2,@snedges)
    @cg = MatchGraph.new(@mg)
    @sg = StarGraph.new(@mg)
    @dg = MatchRedGraph.new(@mg)
  end

  def test_graph
    assert_equal @sg.class, StarGraph
    assert_equal @sg.nodes[4].class, StarNode
    @sg.nodes.each{|k| assert_equal k.next, :choose}
    @sg.nodes.each{|k| assert !k.neighbors.empty?}
    @sg.nodes.each{|k| k.neighbors.each{|j| assert @sg.nodes.include?(j)}}
    [0,1,2,3,4].each{|k| assert @sg.nodes[k].id == k+10}
    p @sg.nodes[1].neighbors.collect{|k| k.id}
  end

  def test_donext
    @sg.nodes.each{|k| k.do_next}
    @sg.nodes.each{|k| puts "#{k.id}-next: #{k.next}"}
    @sg.nodes.each{|k| assert((k.next == :notroot or k.next == :notleaf), "node #{k.id} is not roof or leaf")}
    [0,3,4].each{|k| @sg.nodes[k].next = :notroot}
    [1,2].each{|k| @sg.nodes[k].next = :notleaf}
    @sg.nodes.each{|k| k.do_next}
    [1,2].each{|k| assert @sg.nodes[k].now == :notleaf}
    [0,3,4].each{|k| [1,2].each{|j| assert(@sg.nodes[j].neighbors.include?(@sg.nodes[k]), "#{j} does not neighbor #{k}")}}
    @sg.nodes.each{|k| k.send_status}
    [1,2].each{|k| assert @sg.nodes[k].leaves.empty?}
    [0,3,4].each{|k| assert !@sg.nodes[k].roots.empty?}
    [0,3,4].each do |k|
      [1,2].each do |j|
        assert @sg.nodes[k].roots.include?(@sg.nodes[j])
      end
    end
    [0,3,4].each{|k| assert @sg.nodes[k].leaves.empty?, "#{k} has leaves"}
    @sg.nodes.each{|k| k.do_next}
    [0,3,4].each{|k| assert @sg.nodes[k].now == :leaf}
    [1,2].each{|k| assert @sg.nodes[k].now == :pause}
    @sg.nodes.each{|k| k.send_status}
    [0,3,4].each{|k| assert_not_nil @sg.nodes[k].rp}
    [0,3,4].each{|k| assert @sg.nodes[k].rp.leaves.include?(@sg.nodes[k])}
    @sg.nodes.each{|k| assert k.satlevel == 0.0}
    @sg.nodes.each{|k| k.do_next}
    [0,3,4].each{|k| assert @sg.nodes[k].now == :wait}
    [1,2].each{|k| assert @sg.nodes[k].now == :root}
    @sg.nodes.each{|k| k.send_status}
  end

  def test_sim
    assert @sg.coverable?, "sg is not coverable"
    simu = StarSimulator.new(@sg)
    simm = MatchSimulator.new(@cg)
    simd = MatchRedSimulator.new(@dg)
    sima = SetSimulator.new(@mg)
    assert simu.rg.coverable?, "simu.rg is not coverable"
    assert simd.rg.coverable?, "simd.rg is not coverable"
    assert_equal simu.rg.class, StarGraph
    simu.rg.nodes.each{|k| assert_equal k.class, StarNode}
    simu.rg.nodes.each{|k| assert k.neighbors.length > 1}
    simu.rg.nodes.each{|k| k.neighbors.each{|j| assert_equal j.class, StarNode}}
    simu.rg.nodes.each{|k| assert_equal k.next, :choose}
    simu.set
    simu.rg.nodes.each{|k| assert_equal k.next, :choose}
    simu.sim
    simu.rg.nodes.each{|k| puts "#{k.id}-next: #{k.next}"}
    simu.rg.nodes.each{|k| puts "#{k.id}-sat:  #{k.satlevel}"}
    simm.set
    simm.sim
    simd.set
    assert simd.sim < 500, "simd is larger than 500"
    sima.set
    sima.set_covers
    sima.sim
    simd.rg.nodes.each{|k| puts "#{k.id}-next: #{k.next}"}    
    assert simd.rg.covered?, "simd.rg is not covered"
    assert simm.rg.covered?, "simm.rg is not covered"
    assert simu.rg.covered?, "simu.rg is not covered"
    assert sima.rg.covered?, "sima.rg is not covered"
  end

  def teardown
    @mg.nodes.each{|k| k = nil}
    @sg.nodes.each{|k| k = nil}
    @mg = nil
    @sg = nil
  end
end
