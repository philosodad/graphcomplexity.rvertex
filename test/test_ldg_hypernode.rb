$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'globals'
require 'node_ldg_hyper'
require 'netgen_eep_hyper'
require 'sim'

class TestHyperLDG < Test::Unit::TestCase
  def setup
    @n0 = LDGHyperNode.new(15,5)
  end

  def test_init
    assert_equal @n0.class, LDGHyperNode
  end
end
