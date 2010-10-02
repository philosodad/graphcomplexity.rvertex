$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'
require 'benchmark'

Benchmark.bm(7) do |x|
  g1 = nil
  m1 = nil
  o1 = nil
  x.report("grid") {g1 = GridSimulator.new(10, 2)}
  x.report("match") {m1 = MatchSimulator.new(g1.rg)}
  x.report("obs") {o1 = SetObsNodeGraph.new(g1.rg)}
  x.report("setgrid") {g1.set}
  x.report("setmatch") {m1.set}
end
