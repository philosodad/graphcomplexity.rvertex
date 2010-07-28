$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'cover'
require 'set'

class TestComposer < Test::Unit::TestCase
  include CoverComposer
  def setup
    @m = [[1,1,0,0,0],[1,0,1,0,0],[1,0,0,1,0],[1,0,0,0,1]]
    @l = []
    17.times{|k| @l.push([])}
    @l.each do |k|
      15.times do
        if rand(8) == 0
          k.push(1)
        else
          k.push(0)
        end
      end
    end
  end

  def test_covercomposer
    a = compose_from @m
    b = compose_from @l
    assert_equal a, []
    assert_equal b, []
  end
end
