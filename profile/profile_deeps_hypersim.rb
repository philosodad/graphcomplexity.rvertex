$:.unshift File.join(File.dirname(__FILE__),'..','lib')

#require 'unprof'
#require 'unroller'
require 'globals'
require 'node_eep_hyper'
require 'netgen_eep_hyper'
require 'sim'

Globals.new 15,15,2,22, 40
TargetGraph.new(15,5)

#s1 = DeepsHyperRunningSimulator.new(DeepsHyperGraph.new(TargetGraph.new(15,5))).trace("si")
#s1.set
#s1.long_sim

