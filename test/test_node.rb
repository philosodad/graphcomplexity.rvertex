$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'

class TestNode < Test::Unit::TestCase

  def setup #always required for a test case
    @sn0 = SetNode.new(0)
    @sn1 = SetNode.new(1)
    @sn2 = SetNode.new(2)
    @sn3 = SetNode.new(3)
    @sn10 = SetNode.new(10)
    @sn11 = SetNode.new(11)
    @sn12 = SetNode.new(12)
    @sn13 = SetNode.new(13)
    @sn14 = SetNode.new(14)
    @sn10.neighbors = [@sn11, @sn12, @sn13]
    @sn11.neighbors = [@sn14, @sn13, @sn10]
    @sn12.neighbors = [@sn10, @sn13, @sn14]
    @sn13.neighbors = [@sn10, @sn11, @sn12]
    @sn14.neighbors = [@sn11, @sn12]
    @sn0.neighbors = [@sn1]
    @sn1.neighbors = [@sn0, @sn2]
    @sn2.neighbors = [@sn1]
    @sn0.weight = 3
    @sn1.weight = 10
    @sn2.weight = 3
    @n0 = Node.new(4,5)
    @n1 = Node.new(3,4)
    @n2 = Node.new(2,3)
    @n3 = Node.new(1,2)
    @n4 = Node.new(0,1)
    @n5 = Node.new(5,6)
    @n6 = Node.new(12,24)
    @n4.on = false
    @nodes = [@n0, @n1, @n2, @n3, @n4, @n5]
    @snodes = [@sn0, @sn1, @sn2]
    @snodes2 = [@sn10, @sn11, @sn12, @sn13, @sn14]
    @n0.neighbors = [@n1, @n3, @n4]
    @n1.neighbors = [@n0, @n2, @n3, @n4]
    @n2.neighbors = [@n1, @n3, @n4]
    @n3.neighbors = [@n0, @n1, @n2, @n4]
    @n4.neighbors = [@n0, @n1, @n2, @n3, @n5]
    @n5.neighbors = [@n4] 
    [@nodes, @snodes, @snodes2].each{|k| k.each{|j| j.boot}}
  end

  def test_init
    assert_equal @n0.id, 0
    assert_equal @n4.id, 4
    assert_equal @n3.x, 1
    assert_equal @n3.y, 2
    assert_equal @sn3.id, 3
    assert_equal @n6.id, 6
    assert @n0.weight < 100
    assert @n0.weight.class == Fixnum
  end

  def test_setedges
    for a in @nodes
      a.neighbors.each{|k| assert k.neighbors.include?(a)}
      assert a.neighbors.length == a.edges.length
      a.edges.each{|k| assert k.length == 2}
    end
  end

  def test_covers
    assert_equal Set.new(@sn10.neighbors.collect{|k| k.id}), Set[11,12,13]
    @sn10.neighbors.each{|k| k.edges.each{|j| assert_equal j.length, 2}}
    @sn13.edges.each{|k| assert_equal k.length, 2}
    @sn13.edges.each{|k| assert k.proper_subset?(Set[10,11,12,13])}
    assert_equal @sn13.edges.select{|j| j.proper_subset?(Set[11,12,13])}, [Set[11,13], Set[12,13]]
    nset = Set.new(@sn10.neighbors.collect{|k| k.id})
    assert_equal nset, Set[11,12,13]
    alledges = Set[]
    @sn10.edges.each{|k| alledges.add(k)}
    assert_equal Set.new(@sn10.edges), alledges
    @sn10.neighbors.each do |k|
      k.edges.each do |j|
        alledges.add(j) if j.proper_subset?(nset)
      end
    end
    nodes = @sn10.neighbors.to_set.add(@sn10)
    assert_equal nodes.length, 4
    assert_equal alledges.length, 5
    alledges.each{|k| assert_equal k.length, 2}
    assert_equal alledges, Set[Set[10,11], Set[10,12], Set[10,13], Set[11,13], Set[12,13]]
    alledges = alledges.to_a
    assert_equal alledges.length, 5
    m1 = @n4.matrix
    m2 = @n5.matrix
    m3 = @n0.matrix
    m10 = @sn10.matrix
    fauxm10 = []
    alledges.each{fauxm10.push([])}
    assert_equal fauxm10.length, 5
    assert m1.length == 10
    assert m2.length == 1
    assert m3.length == 6
    assert_equal m10.length, 5
    m1.each{|k| assert k.length == 6}
    m2.each{|k| assert k.length == 2}
    m2.each{|k| assert k[1] == 1}
    m10.each{|k| assert_equal k.length, 4}
    g = 0
    m1.each{|k| g+=1 if k[4] == 1}
    assert_equal g, 5
    x = @n2.onlist.values.select{|k| k == nil}.length
    @n2.on = false
    @n2.set_ons
    y = @n2.onlist.values.select{|k| k == nil}.length
    assert x != y
    g, h = 0, 0 
    @n4.covers.ldnodes.each{|k| g+= k.onremain}
    @n4.update_covers_on 5, false
    @n4.covers.ldnodes.each{|k| h+= k.onremain}
    assert h != g
  end    

  def test_sendstatus
    assert @n4.send_status
  end

  def test_sendinitial
    puts "sn1 covers: #{@sn1.covers.inspect}"
    assert @sn1.send_initial
    puts "sn0 cover[0] #{@sn0.covers.ldnodes[0].inspect}"
    assert @sn0.currentcover == 0
#    assert !@sn0.covers.ldnodes[0].has?(@sn0.id)
#    assert !@sn0.send_initial
  end

  def test_compareons
  end

  def test_transition
    @snodes.each{|k| assert_not_nil k.covers}
    @snodes.each{|k| assert_kind_of k.covers, LdGraph}
    @snodes.each{|k| assert_nothing_raised{k.send_initial}}
#    assert_equal @sn1.covers.ldnodes.length, 2
    puts "SN10 covers: #{@sn10.covers.ldnodes.collect{|k| k.cover}}"
#    assert_equal @sn10.covers.ldnodes.length, 3
#    assert_equal @sn0.transition(@sn1.id, @sn1.on), :sendoff
    assert !@sn0.on
#    assert_equal @sn1.transition(@sn2.id, @sn2.on), true
#    assert @sn1.on
    @sn2.on = false
    @sn1.on = false
    @sn2.update_covers_on @sn1.id, false
    @sn2.update_covers_on @sn2.id, false
#    assert_equal @sn2.transition(@sn1.id, false), :sendon
  end

  def teardown
    @n0.zero_out
    @n0.covers.ldnodes[0].zero_out
    [@nodes, @snodes, @snodes2].each do |i|
      i.each{|k| k.covers.ldnodes.each{|j| j = nil}}
    end
    [@nodes, @snodes, @snodes2].each{|k| k.each{|i| i = nil}}
    [@nodes, @snodes, @snodes2].each{|k| k = nil}
  end
end
