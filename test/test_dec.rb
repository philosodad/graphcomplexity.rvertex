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
    @b = RandomGraph.new(20, 100)
  end

  def test_init
    b = DirectedEdgeColorGraph.new(@b)
    a = DirectedEdgeColorNode.new(@a)
    b.nodes.each{|k|
      assert k.class == DirectedEdgeColorNode, "not a color node, a #{k.class}"
      k.set_edges
      assert !k.edges.empty?, "empty edges"
      k.edges.each{|j| assert j.class == DirectedColorEdge, "not a color edge, a #{j.class}"}
    }
  end

  def test_fsm
    def step x
      x.nodes.each{|k| k.do_next}
    end
    def test_next x, sym
      x.nodes.each{|k| assert k.next == sym, "expected #{sym}, got #{k.next}"}
    end
    b = DirectedEdgeColorGraph.new(@b)
    b.nodes.each{|k| k.set_edges}
    step b
    assert b.nodes.each{|k| assert [:listen, :invite].include?(k.next), "unknown state #{k.next}"}
    step b
    sends = b.nodes.select{|k| k.now == :invite}
    recvs = b.nodes.select{|k| k.now == :listen}
    assert (!sends.empty? and !recvs.empty?), "sends empty?:#{sends.empty?} or recvs empty?:#{recvs.empty?}"
    sends.each{|k| assert k.next == :wait, "wrong state #{k.next}"}
    recvs.each{|k| assert k.next == :respond, "wrong state #{k.next}"}
    step b
    sends.each{|k| assert k.next == :certify, "wrong state #{k.next}"}
    recvs.each{|k| assert k.next == :attend, "wrong state #{k.next}"}
    b.nodes.each{|k| assert [:certify, :attend].include?(k.next), "wrong state #{k.next}"}
    step b
    test_next b, :update
    step b
    test_next b, :exchange
    step b
    test_next b, :choose
  end

  def test_criteria
    a = DirectedEdgeColorNode.new(@a)
    (1..10).each{|k| a.edges.push(DirectedColorEdge.new(k))}
    assert !a.criteria_fulfilled?, "criteria should not be fulfilled!"
  end

  def test_comparison
    b = DirectedEdgeColorGraph.new(@b)
    b.nodes.each{|k| k.set_edges}
    b.nodes.each do |j|
      b.nodes.each do |k|
        if j.edges.length > k.edges.length
          assert j > k
        elsif j.edges.length < k.edges.length
          assert j < k
        elsif j.id < k.id
          assert j < k
        elsif j.id > k.id
          assert j > k
        end
      end
    end
    b.nodes.each{|k| assert !k.criteria_fulfilled?, "criteria wrongly fulfilled"}
  end

  def test_edges
    a = DirectedColorEdge.new 3
    b = DirectedColorEdge.new 3
    assert_equal a+b, 4
    a.color[:in]=234
    assert_equal a.color.length, 2
    assert_equal a.color[:in], 234
    assert_equal a+b, 3
    a.color[:out]=345
    assert_equal a+b, 2
    assert_equal 2+b, 4
  end

  def teardown
    @a.zero_out
    @a = nil
    @b = nil
  end
end



