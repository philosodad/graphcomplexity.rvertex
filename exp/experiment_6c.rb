$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'

class Experiment
  def initialize
    @frequency = [["nodes", "links","pcd", "str","mtc", "two", "total"]]
    @average = [["nodes", "links","pcd", "str","mtc", "two", "total"]]
    @runs = [["nodes", "links","pcd", "str","mtc", "two"]]
    @fails = [["nodes", "links","pcd", "str","mtc", "two"]]
  end
  
  def experiment x
    [40,80,160].each do |i|
      [1.5, 3, 6].each do |k|
        pcdwate = 0
        strwate = 0
        mtcwate = 0
        twowate = 0
        totwate = 0
        pcdbest = 0
        strbest = 0
        mtcbest = 0
        twobest = 0
        pcdfail = 0
        strfail = 0
        mtcfail = 0
        twofail = 0
        pcdruns = 0
        strruns = 0
        mtcruns = 0
        tworuns = 0
        nodes = 0
        links = 0
        x.times do
          g = RandomGraph.new(i, (i*k).to_i)
          links += g.edges.length
          pcd_sim = PCDAllSimulator.new(g)
          str_sim = StarRedSimulator.new(g)
          mtc_sim = MatchRedSimulator.new(g)
          two_sim = MatchSimulator.new(g)
          [pcd_sim, str_sim, mtc_sim, two_sim].each do |k|
            k.set
          end
          totwate += pcd_sim.get_total_weight
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
          c,d,r = runsim pcd_sim, 500
          e,f,y = runsim str_sim, 20000
          g,h,z = runsim mtc_sim, 500
          t,u,v = runsim two_sim, 500
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
          m = [d,f,h,u].select{|k| k > 0}.min 
          if m == d then pcdbest += 1 end
          if m == f then strbest += 1 end
          if m == h then mtcbest += 1 end
        end
        pcdwate = pcdwate / (x - pcdfail).to_f        
        strwate = strwate / (x - strfail).to_f
        mtcwate = mtcwate / (x - mtcfail).to_f
        totwate = totwate / x.to_f
        twowate = twowate / (x - twofail).to_f
        pcdruns = pcdruns / (x - pcdfail).to_f
        strruns = strruns / (x - strfail).to_f
        mtcruns = mtcruns / (x - mtcfail).to_f
        tworuns = tworuns / (x - twofail).to_f
        nodes = k*i
        links = links / x.to_f
        
        @average.push([nodes, links,pcdwate, strwate,mtcwate,twowate,totwate])
        @frequency.push([nodes, links, pcdbest, strbest,mtcbest,twobest,x])
        @runs.push([nodes, links,  pcdruns, strruns,mtcruns,tworuns])
        @fails.push([nodes, links, pcdfail, strfail,mtcfail,twofail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment6c_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment6c_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment6c_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment6c_fa.tab", 'w') {|x|
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
x.experiment 40
x.print_to_file
