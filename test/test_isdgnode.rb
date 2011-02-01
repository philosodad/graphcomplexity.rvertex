$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node_isg'
require 'set'

class TestISGNode < Test::Unit::TestCase

  def setup
    Globals.new()
    @node1 = ISGNode.new(0,0) 
  end

  def testNode
    assert_instance_of ISGNode, @node1
  end

  def teardown
    @node1 = nil
  end
end


