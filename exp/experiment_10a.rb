$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'
require 'globals'
class Experiment

  def initialize
    @average = [["nodes", "links", "delta", "colors", "rounds", "fails"]] 
    Globals.new()
  end
  
  def experiment x
    [50, 100, 200, 500].each do |y|
      [4,8,16].each do |z|
        delta = 0 
        colors = 0
        fails = 0
        rounds = 0  
          nodes = 0
          links = 0
          x.times do
            $stdout.flush
            v = RandomGraph.new(y, (y*z).to_i)
            low = v.get_lower_bound
            links += v.edges.length
            sim = DirectedEdgeColorSimulator.new(v)
            sim.set
            a,b,c = sim.sim(y*100)
            colors += a[0]
            delta += a[1]
            rounds += b
            fails += c
          end
          delta = (delta / (x-fails).to_f).round(0)
          rounds = (rounds / (x-fails).to_f).round(1)
          colors = (colors / (x-fails).to_f).ceil
          nodes = y
          links = z*2
          @average.push([nodes, links, delta, colors, rounds/4, fails])
      end
    end
  end
  
  def print_to_file
    File.open("experiment10_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
  end
end    

x = Experiment.new
x.experiment 50
x.print_to_file
