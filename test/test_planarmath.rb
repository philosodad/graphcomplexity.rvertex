$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','netgens')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','nodes')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','helpers')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','dep_graphs')

require 'test/unit'
require 'node'
require 'planarmath'

class TestPlanarMath < Test::Unit::TestCase
  include PlanarMath
  class Point
    attr_reader :x, :y
    def initialize x,y
      @x = x
      @y = y
    end
  end
      
  def setup
    @n0 = Point.new(30,-20)
    @n1 = Point.new(30,20)
  end
  
  def test_planar
    assert_equal planar_distance(@n0, @n1), 40, 'planar distance not expected'
  end

  def test_coordwithindistance
    500.times do
      x,y = coord_within_distance(@n1, 50)
      g = Point.new(x,y)
      assert planar_distance(@n1,g)<=50, 'point out of distance'
    end
  end

  def teardown
    @n0 = nil
    @n1 = nil
  end
end
