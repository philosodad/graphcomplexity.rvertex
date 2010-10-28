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
    [120, 240,480,960].each do |y|
      [1.5,3,6,12,24,48].each do |z|
        mat_reg_wate = 0
        mat_reg_best = 0
        mat_reg_runs = 0
        mat_reg_fail = 0
        mat_red_wate = 0
        mat_red_best = 0
        mat_red_runs = 0
        mat_red_fail = 0
        sta_reg_wate = 0
        sta_reg_best = 0
        sta_reg_runs = 0
        sta_reg_fail = 0
        sta_red_wate = 0
        sta_red_best = 0
        sta_red_runs = 0
        sta_red_fail = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          u = RandomGraph.new(y, (y*z).to_i)
          low = u.get_lower_bound
          links += u.edges.length
          mat_reg_sim = MatchSimulator.new(u)
          mat_red_sim = MatchRedSimulator.new(u)
          sta_reg_sim = StarSimulator.new(u)
          sta_red_sim = StarRedSimulator.new(u)
          [mat_reg_sim, mat_red_sim, sta_reg_sim, sta_red_sim].each do |w|
            w.set
          end
          a,b,c = mat_reg_sim.sim 500
          d,e,f = mat_red_sim.sim 500
          j,k,l = sta_reg_sim.sim 20000
          m,n,o = sta_red_sim.sim 20000
          mat_reg_wate += a
          mat_reg_runs += b/5
          mat_reg_fail += c
          mat_red_wate += d
          mat_red_runs += (e/5)+3
          mat_red_fail += f
          sta_reg_wate += j
          sta_reg_runs += k/5
          sta_reg_fail += l
          sta_red_wate += m
          sta_red_runs += (n/5)+3
          sta_red_fail += o
          best = [a, d,  j, m ].select{|v| v > 0}.min
          bestcount = 0
          [a,d,j,m].each{|v| if  v == best then bestcount += 1 end}
          if bestcount == 1 then
            if a == best 
              mat_reg_best += 1
            elsif d == best
              mat_red_best += 1
            elsif j == best
              sta_reg_best += 1
            elsif m == best
              sta_red_best += 1
            end
          end
          
        end
        mat_reg_wate = mat_reg_wate / (x-mat_reg_fail).to_f
        mat_red_wate = mat_red_wate / (x-mat_red_fail).to_f
        sta_reg_wate = sta_reg_wate / (x-sta_reg_fail).to_f
        sta_red_wate = sta_red_wate / (x-sta_red_fail).to_f
        mat_reg_runs = mat_reg_runs / (x-mat_reg_fail).to_f
        mat_red_runs = mat_red_runs / (x-mat_red_fail).to_f
        sta_reg_runs = sta_reg_runs / (x-sta_reg_fail).to_f
        sta_red_runs = sta_red_runs / (x-sta_red_fail).to_f
        nodes = y
        links = z*2
        @average.push([nodes, links, mat_reg_wate, mat_red_wate,  sta_reg_wate, sta_red_wate])
        @frequency.push([nodes, links, mat_reg_best, mat_red_best, sta_reg_best, sta_red_best, x])
        @runs.push([nodes, links, mat_reg_runs, mat_red_runs, sta_reg_runs, sta_red_runs])
        @fails.push([nodes, links, mat_reg_fail, mat_red_fail, sta_reg_fail, sta_red_fail])
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
x.experiment 50
x.print_to_file
