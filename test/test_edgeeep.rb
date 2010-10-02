$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'edge_eep'

class TestDeepsEdge < Test::Unit::TestCase
  def setup
    
  end

  def test_equality
    a = DeepsEdge.new(Set[1,2])
    b = DeepsEdge.new(Set[3,4])
    c = DeepsEdge.new(Set[3,4])
    assert a != b, "these are equal and should not be"
    assert_equal c, b
    assert_not_equal a, b
    assert_not_same c, b
    x = [a,b]
    y = [c]
    assert_equal x, [a,c]
    assert_equal y, [b]
    assert b.eql?(c), 'b not eql? to c'
    assert_equal x-y, [a]
  end
  def teardown
  end
end
