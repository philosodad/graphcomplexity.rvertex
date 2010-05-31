$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'netgen'
require 'node'

class TestGraphs < Test::Unit::TestCase

  def setup #always required for a test case
    @n0 = SetNode.new(0)
    @n1 = SetNode.new(1)
    @n2 = SetNode.new(2)
    @n0.weight = 3
    @n1.weight = 1
    @n2.weight = 3
    e1 = Set.new([0,1])
    e2 = Set.new([1,2])
    edges = Set.new([e1,e2])
    @sg = SetGraph.new([@n0, @n1, @n2], edges)
    @udg = UnitDiskGraph.new(80, 100, 120)
    @rg = RandomGraph.new(100,@udg.edges.length)
    @rg1 = RandomGraph.new(20, 120)
    @gg = GridGraph.new(20,1)
    @tg = TotalWeightGraph.new(20,1)
    @mg = MatchGraph.new(@gg)
  end

  def test_mg
    @mg.nodes.each do |k|
      assert @mg.nodes.select{|i| @gg.planar_distance(i,k) < 8 and i != k}.length > 2
    end
    @mg.nodes.each{|k| k.set_edges}
    @mg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}
    @mg.nodes.each{|k| assert_equal k.next, :choose}
    @mg.nodes.each{|k| k.edges.each{|i| assert_equal i.weight, nil}}
  end

  def test_GG
    @gg.nodes.each do |k|
      assert @gg.nodes.select{|i| @gg.planar_distance(i,k) < 8 and i != k}.length > 2
    end
    @gg.nodes.each do |k|
      if @gg.nodes.select{|i| @gg.planar_distance(i,k) < 8 and i != k}.length < 3 then
        puts "\n #{k.x},#{k.y}"
      end
    end
    @gg.nodes.each{|k| k.set_edges}
    @gg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}
    puts "\ngg:#{@gg.nodes.collect{|k| k.neighbors.length}.max}(max)"
    puts "\ngg:#{@gg.nodes.collect{|k| k.neighbors.length}.min}(min)"
    puts "\ngg:#{@udg.nodes.select{|k| k.neighbors.empty?}.length}(disconnected)"
    puts "\ngg:#{@udg.nodes.select{|k| k.neighbors.empty?}.collect{|k| [k.x, k.y]}.inspect}"

  end

  def test_MG
    
    @tg.nodes.each do |k|
      assert @tg.nodes.select{|i| @tg.planar_distance(i,k) < 8 and i != k}.length > 2, "expected #{@tg.nodes.select{|i| @tg.planar_distance(i,k) < 8 and i != k}.length}"
    end
    @tg.nodes.each do |k|
      if @tg.nodes.select{|i| @tg.planar_distance(i,k) < 8 and i != k}.length < 3 then
        puts "\n #{k.x},#{k.y}"
      end
    end
    @tg.nodes.each{|k| k.set_edges}
    @tg.nodes.each{|k| assert_equal k.neighbors.length, k.edges.length}
    puts "\ntg:#{@tg.nodes.collect{|k| k.neighbors.length}.max}(max)"
    puts "\ntg:#{@tg.nodes.collect{|k| k.neighbors.length}.min}(min)"
    puts "\ntg:#{@udg.nodes.select{|k| k.neighbors.empty?}.length}(disconnected)"
    puts "\ntg:#{@udg.nodes.select{|k| k.neighbors.empty?}.collect{|k| [k.x, k.y]}.inspect}"
  end
  
  def test_UDG
#    assert @udg.nodes.length == 400
#    assert @udg.edges.length == 25*49
    @udg.edges.each{|k| assert k.length == 2}
    @udg.nodes.each{|k| k.set_edges}
#    @udg.nodes.each{|k| assert k.neighbors.length == 49}
    @udg.nodes.each{|k| assert k.neighbors.length == k.edges.length}
    puts "\nudg:#{@udg.nodes.collect{|k| k.neighbors.length}.max}(max)"
    puts "\nudg:#{@udg.nodes.collect{|k| k.neighbors.length}.min}(min)"
    puts "\nudg:#{@udg.nodes.select{|k| k.neighbors.empty?}.length}(disconnected)"
    puts "\nudg:#{@udg.nodes.select{|k| k.neighbors.empty?}.collect{|k| [k.x, k.y]}.inspect}"
  end
  
  def test_SG
    @sg.nodes.each{|k| k.set_edges}
    @sg.nodes.each{|k| k.set_covers}
    assert_equal @n1.id, 1
    assert @sg.nodes.length == 3
    assert @sg.edges.length == 2
    @sg.edges.each{|k| assert k.length == 2}
    @sg.edges.each{|k| assert k.include?(@n1.id)}
    assert_equal @n1.neighbors.length, 2
    assert_equal @n0.neighbors.length, 1
    assert_equal @n2.neighbors.length, 1
    @sg.nodes.each{|k| assert_equal k.on, nil}
    assert_equal @n1.covers.class, LdGraph
    assert_equal @n1.covers.ldnodes[0].class, LdNode
    assert_equal @n1.covers.ldnodes.class, Array
    @sg.nodes.each{|k| k.covers.ldnodes.each{|j| assert_equal j.class, LdNode}}
    @sg.nodes.each{|k| assert_equal k.covers.ldnodes.length, 2}
  end

  def test_rg
    @rg.edges.each{|k| assert k.length == 2}
    assert @rg.nodes.length == 100
    assert_equal @rg.edges.length, @udg.edges.length
    puts "\nrg:#{@rg.nodes.collect{|k| k.neighbors.length}.max}(max)"
    puts "\nrg1:#{@rg1.nodes.collect{|k| k.neighbors.length}.max}(max)"
    puts "\nrg:#{@rg.nodes.collect{|k| k.neighbors.length}.min}(min)"
    puts "\nrg1:#{@rg1.nodes.collect{|k| k.neighbors.length}.min}(min)"
  end
end
