$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'netgen'
require 'set'

class TestSimplenode < Test::Unit::TestCase
  def setup
    @nag = NotaGraph.new(160)
#    @bng = NotaGraph.new(320)
  end

  def test_init
    assert_not_nil @nag
    assert_equal @nag.nodes.length, (160*159)-80
    @nag.nodes.each{|k| assert k.class == Node}
    @nag.nodes.each{|k| assert k.x < 25600}
    @nag.nodes.each{|k| assert_equal k.neighbors[2].class, Node}
  end
end

