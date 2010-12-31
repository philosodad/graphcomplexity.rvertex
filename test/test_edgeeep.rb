$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'edge_eep'
require 'globals'
require 'node'

class TestDeepsEdge < Test::Unit::TestCase
  def setup
    Globals.new
    @a = BasicNode.new
    @b = BasicNode.new
    @c = BasicNode.new
    @d = BasicNode.new
  end

  def test_equality
    a = DeepsEdge.new @a, @b
    b = DeepsEdge.new @c, @d
    c = DeepsEdge.new @c, @d
    assert_equal c, b, "b should equal c"
    assert a != b, "these are equal and should not be"
    assert_not_equal a, b, "these are equal and should not be"
    assert_not_same c, b, "these are the same and should not be"
    x = [a,b]
    y = [c]
    assert_equal x, [a,c], "x should equal [a,c]"
    assert y == [b], "y should equal [b]"
    assert b.eql?(c), 'b not eql? to c'
    assert x-y == [a]
  end

  def teardown
    [@a, @b, @c, @d].each{|k| k == nil}
  end
end
