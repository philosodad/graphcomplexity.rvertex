$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'netgen_pcd'
require 'netgen_udg'
require 'node_pcd'
require 'benchmark'

class TestUDG < Test::Unit::TestCase
  include PlanarMath
  def setup
    Globals.new()
    $n = 200
    $d = 5
    @rg = UDG_Graph.new($n,$d)
    @kg = MatchGraph.new(@rg)
  end

  def test_init
    assert_kind_of UDG_Graph, @rg
    @kg.nodes.each{|k| assert_kind_of MatchNode, k}
    assert_equal @kg.nodes.length, $n
    @rg.nodes.each do |k|
      k.neighbors.each do |j|
        assert j.neighbors.include?(k), "neighbor test failed"
      end
      nods = @rg.nodes - [k]
      nods.each do |j|
        if k.neighbors.include?(j)
          assert planar_distance(j,k) <= $distance, "distance test 1 failed"
        elsif !k.neighbors.include?(j)
          assert planar_distance(j,k) >= $distance, "distance test 2 failed, distance is #{planar_distance(j,k)}"
        end
      end

    end
    assert @rg.isolated?($d*3) == true, "rg not isolated"
    assert @rg.isolated?(1) == false, "@rg still isolated"
    assert !@rg.connect?, "rg not connected"
    assert !@kg.isolated?(1), "kg is isolated"
    assert @kg.connect?, "kg connected?"
    @kg.connect!
    assert !@kg.isolated?(1), "kg still isolated"
    assert !@kg.connect?, "kg still unconnected"
  end

  def test_benchmark
    t1 = Benchmark.realtime do 
      g = UDG_Graph.new(80, 12)
    end
    p "build time = #{t1}"
  end

end
