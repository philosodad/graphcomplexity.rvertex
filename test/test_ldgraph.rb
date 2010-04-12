$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'ldgraph'
require 'node'

class TestLdGraph < Test::Unit::TestCase
  def setup
    @n0 = Node.new(4,5)
    @n1 = Node.new(3,4)
    @n2 = Node.new(2,3)
    @testset = Set[Set[0,2], Set[1], Set[0,1,2]]
    @n0.neighbors = [@n2]
    @n1.neighbors = [@n2]
    @n2.neighbors = [@n0, @n1]
  end

  def test_init
    @ld1 = LdGraph.new(@testset, [@n0, @n1, @n2])
    assert @ld1.ldnodes.length == 3
    assert_kind_of @ld1.ldnodes[1], LdNode
    @ld1.ldnodes.each{|k| puts k.inspect}
    puts @ld1.edges.length
    assert @ld1.edges.length == 2
    puts @ld1.edges.inspect
    @ld1.ldnodes.each{|k| puts k.edges.inspect}
  end
end
