$:.unshift File.join(File.dirname(__FILE__),'..','lib')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','dep_graphs')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','helpers')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','nodes')

require 'test/unit'
require 'dep_graphs/dep_graph_ldg'
require 'node'
require 'node_ldg'

class TestLdGraph < Test::Unit::TestCase
end
