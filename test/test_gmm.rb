$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'
require 'set'

class TestGMM < Test::Unit::TestCase
  def setup
    @n0 = Node.new(0,1)
    @mn0 = MatchNode.new(@n0)
    @mn1 = MatchNode.new(0,2)
    @mn2 = MatchNode.new(1,1)
    @mn0.neighbors = [@mn1, @mn2]
    @mn1.neighbors = [@mn0, @mn2]
    @mn2.neighbors = [@mn0, @mn1]
    @mn6 = MatchNode.new(0,0)
    @mn7 = MatchNode.new(1,1)
    @mn6.neighbors = [@mn7]
    @mn7.neighbors = [@mn6]
    @mn6.weight = 80
    @mn7.weight = 60
    @nod2 = [@mn6, @mn7]
    @nod3 = [@mn0, @mn1, @mn2]
  end

  def test_init
    assert_equal @mn0.x, @n0.x
    assert_equal @mn0.y, @n0.y
    assert_equal @mn0.weight, @n0.weight
  end
  
  def test_checkbattery
    @mn0.weight = 70
    @mn1.weight = 10
    [@mn0, @mn1].each{|k| k.set_edges}
    assert_equal @mn0.check_battery, 30
    assert_equal @mn1.check_battery, 90
    @mn0.edges.first.weight = 30
    @mn1.edges.first.weight = 30
    assert_equal @mn0.check_battery, 0
    assert_equal @mn1.check_battery, 60
    @mn1.edges.each{|k| if k.weight == nil then k.weight = 40 end}
    assert_equal @mn1.check_battery, 20
  end
  def test_setedges
    @mn1.set_edges
    @mn1.edges.each{|k| assert_equal k.class, WeightedEdge}
    assert_equal [Set[@mn1.id, @mn2.id], Set[@mn0.id, @mn1.id]] - @mn1.edges.to_a.collect{|k| k.uv}, []
  end

  def test_donext
    @nod2.each{|k| k.set_edges}
    @nod2.each{|k| assert_equal k.on, nil}
    [@mn6, @mn7].each{|k| k.do_next}
    [@mn6, @mn7].each{|k| assert_equal k.now, :choose}
    @nod2.each{|k| k.edges.each{|j| assert_equal j.weight, nil}}
    assert @mn6.edges.to_a.length > 0
    [@mn6, @mn7].each{|k| assert (k.next == :invite or k.next == :listen)}
    @nod2.each{|k| k.send_status}
    @nod2.each{|k| assert_equal k.now, :choose}
    @nod2.each{|k| k.do_next}
    @nod2.each{|k| k.edges.each{|j| assert_equal j.weight, nil}}
    @nod2.each{|k| assert (k.now == :invite or k.now == :listen)}
  end

  def test_sendstatus
    @nod2.each{|k| k.set_edges}
    @mn6.set_now :invite
    @mn7.set_now :listen
    assert_equal @mn6.send_status, true
    assert_equal @mn6.rp, @mn7
    @mn6.edges.each{|k| k.weight = 20}
    @mn6.send_status
    @mn6.edges.each{|k| k.weight = nil}
    @mn7.set_now :respond
    @mn6.weight = 50
    @mn7.weight = 40
    @mn7.send_status
    assert_equal @mn7.rp, @mn6
    assert_equal @mn7.subtract, 50
  end

  def test_recievestatus
    @nod3.each{|k| k.set_edges}
    @mn0.set_next :invite
    @mn1.set_next :invite
    @mn2.set_next :listen
    @mn1.weight = 50
    @mn2.weight = 70
    @mn0.weight = 40
    @nod3.each{|k| k.do_next}
    @mn1.edges.select{|k| k.uv.include?(@mn0.id)}[0].weight = 10
    @mn0.edges.select{|k| k.uv.include?(@mn1.id)}[0].weight = 10
    @nod3.each{|k| k.send_status}
    assert_equal @mn2.invites.length, 2
    assert_equal Set.new(@mn2.invites), Set[@mn0.id, @mn1.id]
    @nod3.each{|k| k.do_next}
    @nod3.each{|k| assert_equal k.next, :update}
    [@mn0, @mn1].each{|k| assert_equal k.now, :wait}
    assert_equal @mn2.now, :respond
    @nod3.each{|k| k.send_status}
    puts @mn2.subtract
    assert_equal @mn0.check_battery, 50
    assert_equal @mn1.check_battery, 40
    [@mn0, @mn1].each{|k| assert_equal k.rp, @mn2}
    assert (@mn2.rp == @mn1 or @mn2.rp == @mn0)
    assert_equal @mn2.rp.subtract, @mn2.subtract
    assert (@mn0.subtract == 0 or @mn1.subtract == 0)
    @nod3.each{|k| k.do_next}
    @nod3.each{|k| assert_equal k.next, :exchange}
    puts @mn2.check_battery
    assert_equal @mn2.on, true
    if @mn2.rp == @mn1 then
      assert_equal @mn1.check_battery, 10
    else
      assert_equal @mn0.check_battery, 20
    end
    @nod3.each{|k| k.send_status}
    @nod3.each{|k| k.do_next}
    @nod3.each{|k| assert_equal k.next, :choose}
    @nod3.each{|k| k.edges.each{|j| assert_not_nil j.weight}}
    assert_equal @mn2.on, true
    @nod3.each{|k| k.send_status}
    @nod3.each{|k| k.do_next}
    @nod3.each{|k| k.send_status}
    @nod3.each{|k| k.do_next}
    @nod3.each{|k| assert_equal k.now, :done}
    assert_equal @mn2.on, true
    @nod3.each{|k| k.send_status}
    @nod3.each{|k| k.do_next}
    assert_equal @mn2.on, true
    [@mn1, @mn0].each{|k| assert_equal k.on, false}
  end

  def test_run
    @nod3.each{|k| k.set_edges}
    until @mn0.now == :done and @mn1.now == :done and @mn2.now == :done
      @nod3.each{|k| k.do_next}
      @nod3.each{|k| k.send_status}
    end
    @nod3.each{|k| assert k.on == true}
  end
  def test_chooseedge
    @mn0.set_edges
    assert_equal @mn0.choose_edge.class, WeightedEdge
    @mn0.edges.each{|k| k.weight = 4}
    assert_equal @mn0.choose_edge, :empty
  end

  def teardown
    @mn1.zero_out
    [@mn0, @mn1, @mn2, @mn6,@mn7].each{|k| k = nil}
  end 
end
