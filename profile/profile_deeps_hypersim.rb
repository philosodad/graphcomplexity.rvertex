$:.unshift File.join(File.dirname(__FILE__),'..','lib')

#require 'ruby-prof'
require 'globals'
require 'node_eep_hyper'
require 'netgen_eep_hyper'
require 'sim'

#RubyProf.start

s1 = DeepsHyperRunningSimulator.new(DeepsHyperGraph.new(TargetGraph.new(15,5)))
s1.set
s1.long_sim

#result = RubyProf.stop

#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT, 0)

