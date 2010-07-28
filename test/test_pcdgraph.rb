$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node_pcd'
require 'netgen'
require 'sim'

class TestLdGraph < Test::Unit::TestCase
  def setup
    @whs = [30, 40, 40, 70, 10, 90, 50, 60, 20]
    @n = []
    (0..8).each{|k| @n[k] = SetNode.new(k)}
    @n.each_index{|k| @n[k].weight = @whs[k]}
    eds = [[0,1],[0,2],[0,3],[1,3],[1,6],[2,3],[2,5],[3,6],[3,4],[4,5],[4,7],[4,6],[5,7],[5,8]]
    @e = Set[]
    eds.each{|k| @e.add(Set.new(k))}
    @setnet = SetGraph.new(@n, @e)
    @net = PCDGraph.new(@setnet)
    @delta = PCDDeltaGraph.new(@setnet)
    @sim = PCDSimulator.new(@setnet)
  end

  def test_setup
    @delta.inspect
    assert_equal @n[0].id, 0
    assert_equal @n[8].weight, 20
    assert @e.include?(Set[5,7])
    assert @net.nodes.each{|k| k.class == PCDNode}
    (0..7).each do |k|
      assert_equal @net.nodes[k].weight, @whs[k]
    end
    assert_equal @net.nodes[3].neighbors.length, 5
    assert @net.nodes[3].neighbors.collect{|k| k.id} - [0,1,2,6,4] == []
  end

  def test_nodes
    puts "test nodes"
    @net.nodes.each{|k| k.build_first_cover}
    @net.nodes.each{|k| k.get_covers}
    assert_equal @net.nodes[3].covers.nodes.length, 6
    @net.nodes.each{|k| k.covers.set_edges}
    @net.nodes.each{|k| assert_equal k.covers.nodes.length, k.neighbors.length + 1}
    assert_equal @net.nodes[5].covers.edges.length, 7
    @net.nodes.each{|k| k.covers.set_degrees}
    c = @net.nodes[5].covers
    c.nodes.sort!
    assert_equal c.nodes.first.ids.sort!, [4,5]
    assert_equal c.nodes.last.ids.sort!, [2,4,7,8]
    c.reduce_weight @net.nodes[2]
    c.nodes.each{|k| puts k.inspect}
  end 

  def test_delta
    puts "test delta"
    @delta.nodes.each{|k| k.build_first_cover}
    @delta.nodes.each{|k| k.get_covers}
    @delta.nodes.each{|k| k.covers.set_edges}
    @delta.nodes.each{|k| k.do_next}
    @delta.nodes.each{|k| assert k.onlist.empty?}
    @delta.nodes.each{|k| k.send_status}
    @delta.nodes.each{|k| assert !k.onlist.empty?}
    @delta.nodes[0].covers.inspect
  end

  def test_sim
    @sim.set
    assert @sim.sim < 500
    w = @sim.rg.nodes.select{|k| k.on}.collect{|k| k.weight}.inject(0){|a,b| a + b}
    puts "weight: #{w}"
    assert @sim.rg.nodes[1].on
    assert !@sim.rg.nodes[6].on
  end
end
