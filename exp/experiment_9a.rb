$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'
require 'globals'
class Experiment

  def initialize
    @average = [["nodes", "links",  "pcd", "deeps", "match"]]
    Globals.new()
  end
  
  def experiment x
    [20,40,80].each do |y|
      [1.5,3,6].each do |z|
        pcdwate = 0
        pcdfail = 0
        depwate = 0
        depfail = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          w = RandomGraph.new(y, (y*z).to_i)
          low = w.get_lower_bound
          links += w.edges.length
          pcd_sim = PCDSteppingSimulator.new(w)
          dep_sim = DeepsSimulator.new(w)
          [pcd_sim, dep_sim].each do |k|
            k.set
          end
          d,e,f = pcd_sim.long_sim
          g,h,i = dep_sim.long_sim
          pcdwate += d
          pcdfail += f
          depwate += g
          depfail += i
        end
        pcdwate = (pcdwate / (x-pcdfail).to_f).round(1)
        depwate = (depwate / (x-depfail).to_f).round(1)
        nodes = y
        links = z*2
        @average.push([nodes, links, pcdwate, depwate])
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
x.experiment 25
x.print_to_file
