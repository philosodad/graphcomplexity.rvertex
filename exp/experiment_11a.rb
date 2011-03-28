$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'
require 'globals'
class Experiment

  def initialize
    @average = [["nodes", "links", "cost", "deeps_step", "deeps_run"]] 
    Globals.new()
  end
  
  def experiment x
    [10,20,40].each do |y|
      [2,4,8].each do |z|
        [1000, 5,4,2,1].each do |w|
          pcd_run_wate = 0
          pcd_run_fail = 0
          dep_run_wate = 0
          dep_run_fail = 0
          pcd_step_wate = 0
          pcd_step_fail = 0
          dep_step_wate = 0
          dep_step_fail = 0
          nodes = 0
          links = 0
          x.times do
            $stdout.flush
            u = TargetGraph.new(z*y,y)
            v = DeepsHyperGraph.new(u)
            links += v.edges.length
            dep_run_sim = DeepsHyperRunningSimulator.new(v)
            dep_step_sim = DeepsHyperSteppingSimulator.new(v)
            [dep_run_sim, dep_step_sim].each do |u|
              u.set
            end
            g,h,i = dep_run_sim.long_sim
            q,r,s = dep_step_sim.long_sim w
            dep_run_wate += g
            dep_run_fail += i
            dep_step_wate += q
            dep_step_fail += s
          end
          dep_run_wate = (dep_run_wate / (x-dep_run_fail).to_f).round(1)
          dep_step_wate = (dep_step_wate / (x-dep_step_fail).to_f).round(1)
          nodes = y
          links = z*2
          cost = 100/w
          @average.push([nodes, links, cost, dep_step_wate,dep_run_wate])
        end
      end
    end
  end
  
  def print_to_file
    File.open("experiment11a_av.tab", 'w') {|x|
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
x.experiment 2
x.print_to_file
