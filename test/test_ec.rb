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
    @b = RandomGraph.new(200, 1600)
  end

  def test_init
    assert_nothing_raised do a = EdgeColorRootNode.new(@a) end
    a = EdgeColorRootNode.new(@a)
    assert a.class == EdgeColorRootNode, "then what is it?"
    assert_equal a.colors.length, 2**12
    assert a.invites.class == Hash
    assert_nothing_raised do b = EdgeColorGraph.new(@b) end
    b = EdgeColorGraph.new(@b)
    b.nodes.each{|k| assert k.next == :choose, "k.next = #{k.next}"}
    assert_nothing_raised do EdgeColorSimulator.new(@b) end
    c = EdgeColorSimulator.new(@b)
    assert_nothing_raised do c.set end
    c.rg.nodes.each{|k| k.edges.each{|j| assert j.class == ColoredEdge, 'that is not a colored edge, its a #{j.class}'}}
    assert c.sim[2] == 0, 'c failed'
    c.rg.nodes.each do |k|
      u = k.edges.collect{|j| j.color}
      u.uniq!
      assert_not_nil u
      assert_equal u.length, k.edges.length, "#{u.length} colors for #{k.edges.length} edges"
      k.edges.each do |j|
        if j.color != nil
          assert k.neighbors.select{|i| j.uv.include?(i.id)}.length == 1
          w = k.neighbors.select{|i| j.uv.include?(i.id)}.first
          e = w.edges.select{|i| i.uv.include?(k.id)}.first
          assert e.color == j.color, "e is the wrong color"
        end
      end
      assert k.edges.select{|j| j.color == nil}.length == 0, "some edges are still nil"
    end
    p c.rg.nodes.collect{|k| k.edges.to_a}.flatten.collect{|k| k.color}.max + 1

    p c.rg.nodes.collect{|k| k.edges.length}.max
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

  def test_send_status
    def nextdo c
      c.nodes.each{|k| k.do_next}
    end
    def sendstatus c
      c.nodes.each{|k| k.send_status}
    end
    b = EdgeColorSimulator.new(@b)
    b.set
    c = b.rg
    nextdo c
    c.nodes.each{|k| assert k.invites == {}, "k.invites = #{k.invites}"}
    sendstatus c
    c.nodes.each do |k|
      assert k.invites == {}
      assert k.rp == nil
    end

    nextdo c
    c.nodes.select{|k| k.now == :invite}.each do |k| 
      assert k.rp != nil, "k.now = #{k.now}, but k.rp = #{k.rp}"
      assert k.invites == {}, "k.now = #{k.now}, but k.invites = #{k.invites}"
    end
    c.nodes.select{|k| k.now == :listen}.each do 
      |k| assert k.rp == nil, "k.now = #{k.now}, but k.rp = #{k.rp}"
      assert k.invites == {}, "k.now = #{k.now}, but k.invites = #{k.invites}"
    end
    c.nodes.each{|k| assert [:invite, :listen].include?(k.now), "k.now is #{k.now}"}

    sendstatus c
    c.nodes.select{|k| k.now == :invite}.each do |k| 
      assert k.rp != nil, "k.now = #{k.now}, but k.rp = #{k.rp}"
      assert k.invites == {}, "k.now = #{k.now}, but k.invites = #{k.invites}"
      assert k.rp.class == EdgeColorNode, "k.rp is a #{k.rp.class}"
    end
    c.nodes.select{|k| k.now == :listen}.each do |k| 
      assert k.rp == nil, "k.now = #{k.now}, but k.rp = #{k.rp}"
    end
    assert c.nodes.select{|k| k.invites.length > 0}.length > 0, "no node has an invitation"
  
    nextdo c
    c.nodes.each{|k| assert k.rp != nil, "a node with invitations has no rp" if k.invites.length > 0}
    c.nodes.each{|k| assert [:wait, :respond].include?(k.now), "k.now is #{k.now}"}
    c.nodes.select{|k| k.now == :wait}.each do |k| 
      assert k.rp != nil, "k.now = #{k.now}, but k.rp = #{k.rp}"
      assert k.invites == {}, "k.now = #{k.now}, but k.invites = #{k.invites}"
      assert k.rp.class == EdgeColorNode, "k.rp is a #{k.rp.class}"
    end

    sendstatus c
    c.nodes.each{|k| assert [:wait, :respond].include?(k.now), "k.now is #{k.now}"}
    c.nodes.select{|k| k.rp == nil}.each{|k| assert ((k.now == :wait) or (k.now == :respond and k.invites.length == 0)), "k.now = #{k.now}, k.invites.length = #{k.invites.length}"}
    c.nodes.select{|k| k.invites.length > 0}.each{|k| assert k.rp != nil, "k.now = #{k.now}, k.invites = #{k.invites}, k.rp = #{k.rp}"}

    nextdo c
    c.nodes.each{|k| assert k.now == :update}
    c.nodes.each do |k|
      k.edges.each do |j|
        if j.color != nil
          assert k.neighbors.select{|i| j.uv.include?(i.id)}.length == 1
          w = k.neighbors.select{|i| j.uv.include?(i.id)}.first
          e = w.edges.select{|i| i.uv.include?(k.id)}.first
          assert e.color == j.color, "e is the wrong color"
        end
      end
    end
  end

  def teardown
    @a = nil
    @b = nil
  end
end
