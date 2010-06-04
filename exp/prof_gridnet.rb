$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'

@g1 = GridSimulator.new(40, 2)
# @g2 = MatchSimulator.new(@g1.rg)

# @g2.set
# @g2.sim
