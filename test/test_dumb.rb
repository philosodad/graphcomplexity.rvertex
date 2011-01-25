$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'

class TestSim < Test::Unit::TestCase
  def setup
    @dg = DumbRedSimulator.new(RandomGraph.new(30,90))
  end

  def test_dumb
    @dg.set
    assert @dg.sim < 500, "dg greater than 500!"
  end

  def teardown
    @dg = nil
  end
end
