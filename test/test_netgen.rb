$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'netgen'

class TestGraphs < Test::Unit::TestCase

  def setup #always required for a test case
  end

  def test_UDG
    @udg = UnitDiskGraph.new(50, 500, 1000)
    assert @udg.nodes.length == 50
    assert @udg.edges.length == 25*49
    @udg.edges.each{|k| assert k.length == 2}
    @udg.nodes.each{|k| k.set_edges}
    @udg.nodes.each{|k| assert k.neighbors.length == 49}
    @udg.nodes.each{|k| assert k.neighbors.length == k.edges.length}
  end
end
