$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'

class Experiment
  def initialize
    @frequency = [["nodes", "links" "ldg", "pcd", "str","mtc", "two", "total"]]
    @average = [["nodes", "links", "ldg", "pcd", "str","mtc", "two", "total"]]
    @runs = [["nodes", "links", "ldg", "pcd", "str","mtc", "two"]]
    @fails = [["nodes", "links", "ldg", "pcd", "str","mtc", "two"]]
  end
  
  def experiment x
    [40,80, 160].each do |i|
      [1.5, 3, 6].each do |k|
        ldgwate = 0
        pcdwate = 0
        strwate = 0
        mtcwate = 0
        twowate = 0
        totwate = 0
        ldgbest = 0
        pcdbest = 0
        strbest = 0
        mtcbest = 0
        twobest = 0
        ldgfail = 0
        pcdfail = 0
        strfail = 0
        mtcfail = 0
        twofail = 0
        ldgruns = 0
        pcdruns = 0
        strruns = 0
        mtcruns = 0
        tworuns = 0
        nodes = 0
        links = 0
        x.times do
          g = RandomGraph.new(i, (i*k).to_i)
          links += g.edges.length
          ldg_sim = RandomRedSimulator.new(g)
          pcd_sim = PCDAllSimulator.new(g)
          str_sim = StarRedSimulator.new(g)
          mtc_sim = MatchRedSimulator.new(g)
          two_sim = MatchSimulator.new(g)
          [ldg_sim, pcd_sim, str_sim, mtc_sim, two_sim].each do |k|
            k.set
          end
          ldg_sim.set_covers
          totwate += ldg_sim.get_total_weight
          def runsim which, long
            fa = 0
            we = 0
            nr = which.sim 
            if nr > long then
              fa = 1
              nr = 0
            else
              we = which.get_on_weight
            end
            return fa, we, nr
          end
          a,b,q = runsim ldg_sim, 500
          c,d,r = runsim pcd_sim, 500
          e,f,y = runsim str_sim, 20000
          g,h,z = runsim mtc_sim, 500
          t,u,v = runsim two_sim, 500
          ldgwate += b
          ldgfail += a
          pcdwate += d
          pcdfail += c
          strwate += f
          twowate += u
          strfail += e
          mtcwate += h
          mtcfail += g
          twofail += t
          ldgruns += q
          pcdruns += r
          strruns += y
          mtcruns += z
          tworuns += v
          m = [b,d,f,h,u].select{|k| k > 0}.min 
          if m == b then ldgbest += 1 end
          if m == d then pcdbest += 1 end
          if m == f then strbest += 1 end
          if m == h then mtcbest += 1 end
        end
        ldgwate = ldgwate / (x - ldgfail).to_f
        pcdwate = pcdwate / (x - pcdfail).to_f        
        ldgwate = strwate / (x - strfail).to_f
        ldgwate = mtcwate / (x - mtcfail).to_f
        totwate = totwate / x.to_f
        twowate = twowate / (x - twofail).to_f
        ldgruns = ldgruns / (x - ldgfail).to_f
        pcdruns = pcdruns / (x - pcdfail).to_f
        strruns = strruns / (x - strfail).to_f
        mtcruns = mtcruns / (x - mtcfail).to_f
        tworuns = tworuns / (x - twofail).to_f
        nodes = k*i
        links = links / x.to_f
        
        @average.push([nodes, links, ldgwate, pcdwate, strwate,mtcwate,twowate,totwate])
        @frequency.push([nodes, links, ldgbest, pcdbest, strbest,mtcbest,twobest,x])
        @runs.push([nodes, links, ldgruns, pcdruns, strruns,mtcruns,tworuns])
        @fails.push([nodes, links, ldgfail, pcdfail, strfail,mtcfail,twofail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment6_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment6_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment6_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment6_fa.tab", 'w') {|x|
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
x.experiment 30
x.print_to_file
