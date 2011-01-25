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
    @b = RandomGraph.new(500, 7400)
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
    def test_next x, *args
        if args.length == 1
          sym = args[0]
          x.nodes.each{|k| assert k.next == sym, "expected #{sym}, got #{k.next}"}
        else
          x.nodes.each{|k| assert args.include?(k.next)}
        end
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
    test_next b, :update_in, :update_out
    step b
    test_next b, :exchange
    step b
    test_next b, :choose
  end

  def test_send
    def nxst x
      x.nodes.each{|k| k.do_next}
    end
    def sdst x
      x.nodes.each{|k| k.send_status}
    end
    b = DirectedEdgeColorGraph.new(@b)
    b.nodes.each{|k| k.set_edges}
    nxst b
    sdst b
    nxst b
    inviters = b.nodes.select{|k| k.now == :invite}.length
    listeners = b.nodes.select{|k| k.now == :listen}.length
    assert b.nodes.length == inviters + listeners, "missing some nodes from inviters and listeners"
    assert inviters > 0, "no inviters"
    assert listeners > 0, "no listeners"
    b.nodes.each{|k| if k.now == :listen then assert_nil k.rp end}
    b.nodes.each{|k| if k.now == :invite then assert_not_nil k.rp end}
    sdst b
    b.nodes.each{|k| if k.now == :invite then assert k.test_next_message else assert !k.test_next_message end}
    b.nodes.each{|k| if k.now == :listen then assert (!k.invites.empty? or k.neighbors.each{|j| j.rp != k}) end}
    nxst b
    assert b.nodes.select{|k| k.now == :respond}.select{|k| k.test_next_message}.any?
    sdst b
    assert b.nodes.select{|k| k.now == :wait}.select{|k| k.invites.any?}.any?
    nxst b
    assert b.nodes.select{|k| k.invites.any?}.empty?
    t = b.nodes.select{|k| k.edges.reduce(:+) < (k.edges.length * 2)}
    assert t.any?
    assert t.length < b.nodes.length
    t.each do |k|
      assert k.edges.select{|k| k.to_i < 2}.length < 2
      e = k.edges.select{|j| j.uv.include? k.rp.id}
      f = k.rp.edges.select{|j| j.uv.include? k.id}
      assert e.length == 1
      assert f.length == 1
      e = e.first
      f = f.first
      assert e.color[:in] == f.color[:out]
      assert e.color[:out] == f.color[:in]
    end
    sdst b
    assert b.nodes.select{|k| k.invites.empty?}.empty?
    nxst b
    sdst b
    
  end

  def test_sim
    c = DirectedEdgeColorSimulator.new(@b)
    c.set
    c.rg.nodes.each{|k| assert k.edges.any?}
    p c.sim(c.rg.nodes.collect{|k| k.edges.length}.max * 40)
    c.rg.nodes.each do |k|
      assert k.edges.collect{|k| k.color.values}.flatten.length == k.edges.length * 2
      k.edges.each do |j|
        i = j.color[:in]
        b = 0
        k.neighbors.each do |l|
          l.edges.each do |n|
            if n.color[:out] == i
              b += 1
            end
          end
        end unless i == nil
        assert_equal b, 1
      end
    end
    m = []
    c.rg.nodes.each do |k|
      k.edges.each do |j|
        m = m + j.color.values
        m.uniq!
      end
    end
    p "colors: #{m.length}"
    p "delta: #{c.rg.nodes.collect{|k| k.edges.length}.max}"

  end
  def test_updateedges
    a = DirectedEdgeColorNode.new(0,0)
    b = DirectedEdgeColorNode.new(0,0)
    a.neighbors.push(b)
    b.neighbors.push(a)
    [a,b].each{|k| k.set_edges}
    [a,b].each{|k| assert_equal k.edges.length, 1}
    a.choose_role
    a.set_now(:invite)
    a.choose_round_partner
    a.get_next_message
    a.edges.each{|k|
      assert k.class == DirectedColorEdge, "not a DCE"
      assert k.uv.class == Set
      k.uv.each{|k| assert k.kind_of?(Fixnum), "uv not a fixnum"}
    }
    a.set_now(:update_in)
    a.update_edges
    ae = a.edges.select{|k| k.uv.include?(a.rp.id)}.first
    assert_equal ae.color[:in], 5
    assert a.colors.include?(0), "a does not have 0"
    a.update_colors
    assert !a.colors.include?(0), "a has 0!"
  end

  def test_criteria
    a = DirectedEdgeColorNode.new(@a)
    (1..10).each{|k| a.edges.add(DirectedColorEdge.new(k))}
    assert !a.criteria_fulfilled?, "criteria should not be fulfilled!"
    assert_equal a.edges.length, 10
    a.edges.each{|k| k.color[:in] = 5; k}
     assert !a.criteria_fulfilled?, "criteria should not be fulfilled!"   
    a.edges.each{|k| k.color[:out] = 10}
    assert a.criteria_fulfilled?, "criteria should be fulfilled"
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
    assert_equal 2, b.to_i
  end

  def teardown
    @a.zero_out
    @a = nil
    @b = nil
  end
end



