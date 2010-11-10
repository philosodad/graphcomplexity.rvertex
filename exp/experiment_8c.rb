$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'
require 'globals'
class Experiment

  def initialize
    @frequency = [["nodes", "links", "mat-reg", "mat-red","pcd-red", "star-reg", "star-red",  "total"]]
    @average = [["nodes", "links", "mat-reg", "mat-red", "star-reg", "star-red", "deeps-min"]]
    @runs = [["nodes", "links", "mat-reg", "mat-red", "star-reg", "star-red"]]
    @fails = [["nodes", "links", "pcd-red", "deeps-min"]]
    Globals.new()
  end
  
  def experiment x
    [120, 1200, 12000,120000].each do |y|
      [1.5,3,6].each do |z|
        mat_reg_wate = 0
        mat_reg_best = 0
        mat_reg_runs = 0
        mat_reg_fail = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          u = RandomGraph.new(y, (y*z).to_i)
          low = u.get_lower_bound
          links += u.edges.length
          mat_reg_sim = MatchSimulator.new(u)
          mat_reg_sim.set
          a,b,c = mat_reg_sim.sim 500
          mat_reg_wate += a
          mat_reg_runs += b/5
          mat_reg_fail += c
        end
        mat_reg_wate = mat_reg_wate / (x-mat_reg_fail).to_f
        mat_reg_runs = mat_reg_runs / (x-mat_reg_fail).to_f
        nodes = y
        links = z*2
        @average.push([nodes, links, mat_reg_wate])
        @frequency.push([nodes, links, mat_reg_best, x])
        @runs.push([nodes, links, mat_reg_runs])
        @fails.push([nodes, links, mat_reg_fail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment8b_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment8b_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment8b_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment8b_fa.tab", 'w') {|x|
      @fails.each_index do |k|
        s = String.new
        @fails[k].each_index do |i|
          s << @fails[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }

  end
end    

x = Experiment.new
x.experiment 25
x.print_to_file
