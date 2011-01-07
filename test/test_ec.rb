$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node_ec'
require 'netgen_ec'
require 'globals'
require 'sim'

class TestEC < Test::Unit::TestCase
  def setup
    Globals.new()
    @a = BaseNode.new
    @b = RandomGraph.new(20, 80)
  end

  def test_init
    assert_nothing_raised do a = EdgeColorRootNode.new(@a) end
    a = EdgeColorRootNode.new(@a)
    assert a.class == EdgeColorRootNode, "then what is it?"
    assert_equal a.colors.length, 2**12
    assert_nothing_raised do b = EdgeColorGraph.new(@b) end
    b = EdgeColorGraph.new(@b)
    b.nodes.each{|k| assert k.next == :choose, "k.next = #{k.next}"}
    assert_nothing_raised do EdgeColorSimulator.new(@b) end
    c = EdgeColorSimulator.new(@b)
    assert_nothing_raised do c.set end
    c.rg.nodes.each{|k| k.edges.each{|j| assert j.class == ColoredEdge, 'that is not a colored edge, its a #{j.class}'}}
    assert c.sim[2] == 0, 'c failed'
  end

  def test_fsm
    def step x
      x.nodes.each{|k| k.do_next}
    end
    b = EdgeColorSimulator.new(@b)
    b.set
    c = b.rg
    c.nodes.each{|k| k.do_next}
    c.nodes.each{|k| assert [:invite, :listen].include?(k.next), "#{k.id}.next == #{k.next}"}

    i = c.nodes.select{|k| k.next == :invite}
    j = c.nodes.select{|k| k.next == :listen}
    step c
    i.each{|k| assert k.next == :wait, "expect :wait, got #{k.next}"}
    j.each{|k| assert k.next == :respond, "expect :update, got #{k.next}"}
    step c
    i.each{|k| assert k.next == :update, "expect :update, got #{k.next}"}
    j.each{|k| assert k.next == :update, "expect :update, got #{k.next}"}
    step c
    c.nodes.each{|k| assert k.next == :exchange, "expect :exchange, got #{k.next}"}
    step c
    c.nodes.each{|k| assert k.next == :choose, "expect :choose, got #{k.next}"}
  end
end
