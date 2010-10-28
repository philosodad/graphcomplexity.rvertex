$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'netgen'
require 'node'

class TestGraphs < Test::Unit::TestCase
  def test_init
    [20].each do |k|
      @udg = UnitDiskGraph.new(k**2, k, 8)
#      @rg = RandomGraph.new(@udg.nodes.length,@udg.edges.length)
    end
  end
end
