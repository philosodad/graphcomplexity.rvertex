$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'
require 'netgen'

class TestMatch < Test::Unit::TestCase
  def test_rand
    gs = GridSimulator.new(5,2)
    gs.set
    gs.set_covers
    gs.sim
    puts gs.getOnWeight
  end

  def test_match
    gs = GridSimulator.new(5,2)
    puts "#{gs.rg.class}"
    ms = MatchSimulator.new(gs.rg)
    puts "#{ms.rg.class}"
    puts "#{ms.rg.nodes.length}"
    ms.rg.setNeighbors
    puts ms.rg.nodes[0].neighbors.inspect
    ms.set
    ms.sim
    puts ms.getOnWeight
  end
end
