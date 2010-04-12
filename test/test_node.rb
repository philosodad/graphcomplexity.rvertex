$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'

class TestNode < Test::Unit::TestCase

  def setup #always required for a test case
    @n0 = Node.new(4,5)
    @n1 = Node.new(3,4)
    @n2 = Node.new(2,3)
    @n3 = Node.new(1,2)
    @n4 = Node.new(0,1)
    @n5 = Node.new(5,6)
    @nodes = [@n0, @n1, @n2, @n3, @n4, @n5]
    @n0.neighbors = [@n1, @n3, @n4]
    @n1.neighbors = [@n0, @n2, @n3, @n4]
    @n2.neighbors = [@n1, @n3, @n4]
    @n3.neighbors = [@n0, @n1, @n2, @n4]
    @n4.neighbors = [@n0, @n1, @n2, @n3, @n5]
    @n5.neighbors = [@n4]
  end

  def test_init
    assert_equal @n0.id, 0
    assert_equal @n4.id, 4
    assert_equal @n3.x, 1
    assert_equal @n3.y, 2
    assert @n0.weight < 50
    assert @n0.weight.class == Fixnum
  end

  def test_setedges
    @nodes.each{|k| k.set_edges}
    for a in @nodes
      a.neighbors.each{|k| assert k.neighbors.include?(a)}
      assert a.neighbors.length == a.edges.length
      a.edges.each{|k| assert k.length == 2}
    end
  end

  def test_covers
    @nodes.each{|k| k.set_edges}
    @n4.set_covers
    @n5.set_covers
    m1 = @n4.matrix
    m2 = @n5.matrix
    assert m1.length == 10
    assert m2.length == 5
    m1.each{|k| assert k.length == 6}
    m2.each{|k| assert k.length == 6}
    m2.each{|k| assert k[4] == 1}
    g = 0
    m1.each{|k| g+=1 if k[4] == 1}
    assert_equal g, 5
    puts @n4.covers.inspect
    puts @n5.covers.length
    @n4.covers.each{|k| assert @n4.edges.each{|j| !(k.intersection(j).empty?)}}
  end

  def teardown
    @n0.zero_out
    @nodes.each{|k| k = nil}
    @nodes = nil
  end
end
