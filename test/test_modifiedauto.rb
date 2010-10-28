$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'node'
require 'set'

class TestNode < Test::Unit::TestCase

  def setup #always required for a test case
    @sn10 = SetNode.new(10)
    @sn11 = SetNode.new(11)
    @sn12 = SetNode.new(12)
    @sn13 = SetNode.new(13)
    @sn14 = SetNode.new(14)
    @sn15 = SetNode.new(15)
    @sn10.neighbors = [@sn11, @sn12, @sn13]
    @sn11.neighbors = [@sn14, @sn13, @sn10]
    @sn12.neighbors = [@sn10, @sn13, @sn14]
    @sn13.neighbors = [@sn10, @sn11, @sn12]
    @sn14.neighbors = [@sn11, @sn12]
    @sn10.weight = 100
    @sn11.weight = 45
    @sn12.weight = 45
    @sn13.weight = 50
    @sn14.weight = 100
    @snodes2 = [@sn10, @sn11, @sn12, @sn13, @sn14]
  end

  def test_init
    @snodes2.each{|k| assert_equal k.next, :analyze}
  end

  def test_donext
    @snodes2.each{|k| k.set_edges}
    @snodes2.each{|k| k.set_covers}
    @snodes2.each{|k| k.do_next}
    @snodes2.each{|k| assert k.on != false}
    assert @sn11.on == true
    assert @sn14.on == true
    assert @sn12.on == true
    [@sn13, @sn10].each{|k| assert_equal k.on, nil}
    @snodes2.each{|k| k.send_status}
    @snodes2.each{|k| assert k.next == :analyze}
    @snodes2.each{|k| k.do_next}
    assert @sn14.on == false
    assert @sn10.on == nil
    assert @sn13.on == true
    @snodes2.each{|k| k.send_status}
    @snodes2.each{|k| k.do_next}
    @snodes2.each{|k| assert_not_nil k.on}
    @snodes2.each{|k| assert k.next == :done}
    [@sn11, @sn12, @sn13].each{|k| assert k.on}
    [@sn10, @sn14].each{|k| assert !k.on}
  end
end
