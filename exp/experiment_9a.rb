$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'
require 'globals'
class Experiment

  def initialize
    @average = [["nodes", "links",  "pcd", "deeps", "match"]]
    Globals.new()
  end
  
  def experiment x
    [30].each do |y|
      [1, 1.5].each do |z|
        matwate = 0
        matfail = 0
        pcdwate = 0
        pcdfail = 0
        depwate = 0
        depfail = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          g = RandomGraph.new(y, (y*z).to_i)
          low = g.get_lower_bound
          links += g.edges.length
          mat_sim = MatchStepSimulator.new(g)
          pcd_sim = PCDSteppingSimulator.new(g)
          dep_sim = DeepsSimulator.new(g)
          [mat_sim, pcd_sim, dep_sim].each do |k|
            k.set
          end
          def runsim which
            life, runs, fails = which.long_sim 
            return life, runs, fails
          end
          a,b,c = mat_sim.long_sim
          d,e,f = pcd_sim.long_sim
          g,h,i = dep_sim.long_sim
          matwate += a
          matfail += c
          pcdwate += d
          pcdfail += f
          depwate += g
          depfail += i
        end
        matwate = (matwate / (x-matfail).to_f).round(1)
        pcdwate = (pcdwate / (x-pcdfail).to_f).round(1)
        depwate = (depwate / (x-depfail).to_f).round(1)
        nodes = y
        links = z*2
        @average.push([nodes, links, pcdwate, depwate, matwate])
      end
    end
  end
  
  def print_to_file
    File.open("experiment9a_av.tab", 'w') {|x|
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
x.experiment 5
x.print_to_file
