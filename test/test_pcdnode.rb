$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'set'
require 'node_pcd'

class TestPDCnode < Test::Unit::TestCase

  def setup #always required for a test case
    @sn10 = SetNode.new(5)
    @pn10 = PCDNode.new(@sn10)
  end
  
  def test_init

  end


  def teardown
  end
  
end
