$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'
require 'globals'
class Experiment

  def initialize
    @average = [["nodes", "links", "cost", "pcd_step", "pcd_run", "deeps_step", "deeps_run"]] 
    Globals.new()
  end
  
  def experiment x
    [20,40,80].each do |y|
      [1.5,3,6].each do |z|
        [1000, 5, 4, 2, 1].each do |w|
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
            v = UDG_Graph.new(y, z)
            low = v.get_lower_bound
            links += v.edges.length
            pcd_run_sim = PCDAllSimulator.new(v)
            dep_run_sim = DeepsRunningSimulator.new(v)
            pcd_step_sim = PCDSteppingSimulator.new(v)
            dep_step_sim = DeepsSimulator.new(v)
            [pcd_run_sim, dep_run_sim, pcd_step_sim, dep_step_sim].each do |u|
              u.set
            end
            d,e,f = pcd_run_sim.long_sim
            g,h,i = dep_run_sim.long_sim
            m,n,o = pcd_step_sim.long_sim w
            q,r,s = dep_step_sim.long_sim w
            pcd_run_wate += d
            pcd_run_fail += f
            dep_run_wate += g
            dep_run_fail += i
            pcd_step_wate += m
            pcd_step_fail += o
            dep_step_wate += q
            dep_step_fail += s
          end
          pcd_run_wate = (pcd_run_wate / (x-pcd_run_fail).to_f).round(1)
          dep_run_wate = (dep_run_wate / (x-dep_run_fail).to_f).round(1)
          pcd_step_wate = (pcd_step_wate / (x-pcd_step_fail).to_f).round(1)
          dep_step_wate = (dep_step_wate / (x-dep_step_fail).to_f).round(1)
          nodes = y
          links = z*2
          cost = 100/w
          @average.push([nodes, links, cost, pcd_step_wate,pcd_run_wate, dep_step_wate,dep_run_wate])
        end
      end
    end
  end
  
  def print_to_file
    File.open("experiment9d_av.tab", 'w') {|x|
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
