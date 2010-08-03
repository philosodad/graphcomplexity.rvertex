$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'cover'
require 'set'
require 'node'

class TestComposer < Test::Unit::TestCase
  include CoverComposer
  def setup
    @sn10 = SetNode.new(10)
    @sn11 = SetNode.new(11)
    @sn12 = SetNode.new(12)
    @sn13 = SetNode.new(13)
    @sn14 = SetNode.new(14)
    @sn15 = SetNode.new(15)
    @sn10.weight = 5
    @sn11.weight = 15
    @sn12.weight = 20
    @sn13.weight = 30
    @sn14.weight = 10
    @snodes = [@sn10, @sn11, @sn12, @sn13, @sn14]
    @snedge = Set[Set[10,11], Set[10,12], Set[10,13], Set[11,13],Set[11,14], Set[12,13], Set[12,14]]
    @m = [[1,1,0,0,0],[1,0,1,0,0],[1,0,0,1,0],[1,0,0,0,1]]
=begin    @l = []
    17.times{|k| @l.push([])}
    @l.each do |k|
      15.times do
        if rand(8) == 0
          k.push(1)
        else
          k.push(0)
        end
      end
=end    end
  end

  def test_covercomposer
    a = compose_from @m, [5,6,2,8,9]
    b,c = build_matrix @snodes, @snedge
    d = compose_from b,c
    assert d.include?([10,10,10,13,14,13,14])
    e = covers_to_set d
    assert e.include?(Set[11,12,13])
    puts e.inspect
  end
end
