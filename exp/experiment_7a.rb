$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'

class Experiment
  def initialize
    @frequency = [["nodes", "links", "ldg", "pcd","mtc", "total"]]
    @average = [["nodes", "links", "ldg", "pcd","mtc"]]
    @runs = [["nodes", "links", "ldg", "pcd","mtc",]]
    @fails = [["nodes", "links", "ldg", "pcd","mtc"]]
  end
  
  def experiment x
    [20,40].each do |i|
      [1.5, 3].each do |k|
        ldgwate = 0
        pcdwate = 0
        mtcwate = 0
        totwate = 0
        ldgbest = 0
        pcdbest = 0
        mtcbest = 0
        ldgfail = 0
        pcdfail = 0
        mtcfail = 0
        ldgruns = 0
        pcdruns = 0
        mtcruns = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          g = RandomGraph.new(i, (i*k).to_i)
          links += g.edges.length
          ldg_sim = RandomRedSimulator.new(g)
          pcd_sim = PCDAllSimulator.new(g)
          mtc_sim = MatchRedSimulator.new(g)
          [ldg_sim, pcd_sim, mtc_sim].each do |k|
            k.set
          end
          ldg_sim.set_covers
          def runsim which, long
            fa = 0
            we = 0
            life, runs, fails = which.long_sim 
#            if nr > long then
#              fa = 1
#              nr = 0
#            else
#              we = which.get_on_weight
#            end
            return life, runs, fails
          end
          a,b,q = runsim ldg_sim, 500
          c,d,r = runsim pcd_sim, 500
          g,h,z = runsim mtc_sim, 500
          ldgwate += a
          ldgfail = q
          pcdwate += c
          pcdfail = r
          mtcwate += g
          mtcfail = z
          ldgruns = b
          pcdruns = d
          mtcruns = h
          m = [a,c,g].select{|k| k > 0}.max 
          if m == a then ldgbest += 1 end
          if m == c then pcdbest += 1 end
          if m == g then mtcbest += 1 end
        end
        ldgwate = ldgwate / x.to_f
        pcdwate = pcdwate / x.to_f        
        mtcwate = mtcwate / x.to_f
#        ldgruns = ldgruns / (x - ldgfail).to_f
#        pcdruns = pcdruns / (x - pcdfail).to_f
#        mtcruns = mtcruns / (x - mtcfail).to_f
        nodes = i
        links = links / x.to_f
        
        @average.push([nodes, links, ldgwate, pcdwate,mtcwate])
        @frequency.push([nodes, links, ldgbest, pcdbest, mtcbest,x])
        @runs.push([nodes, links, ldgruns, pcdruns,mtcruns])
        @fails.push([nodes, links, ldgfail, pcdfail,mtcfail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment7a_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7a_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7a_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7a_fa.tab", 'w') {|x|
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
x.experiment 10
x.print_to_file
