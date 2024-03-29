$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'
require 'netgen'

class TestMatch < Test::Unit::TestCase
  def setup
    Globals.new()
  end

  def test_rand
    gs = GridSimulator.new(5,2)
    gs.set
    gs.set_covers
    gs.sim
    puts gs.get_on_weight
  end

  def test_match
    gs = GridSimulator.new(5,2)
    puts "#{gs.rg.class}"
    ms = MatchSimulator.new(gs.rg)
    puts "#{ms.rg.class}"
    puts "#{ms.rg.nodes.length}"
    ms.rg.set_neighbors
    puts ms.rg.nodes[0].neighbors.inspect
    ms.set
    ms.sim
    puts ms.get_on_weight
  end
end
