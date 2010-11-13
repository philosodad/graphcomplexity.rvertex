$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node_isdg'
require 'set'

class TestISDGNode < Test::Unit::TestCase

  def setup
    Globals.new()
    @node1 = ISDGRoot.new
  end

  def testNode
    assert_instance_of ISDGRoot, @node1
  end

  def teardown
    @node1 = nil
  end
end


