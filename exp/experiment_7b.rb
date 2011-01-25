$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'

class Experiment
  def initialize
    @frequency = [["nodes", "links", "fcd", "pcd", "total"]]
    @average = [["nodes", "links", "fcd", "pcd"]]
    @runs = [["nodes", "links", "fcd", "pcd"]]
    @fails = [["nodes", "links", "fcd", "pcd"]]
  end
  
  def experiment x
    [15, 30].each do |i|
      [1, 1.5].each do |k|
        fcdwate = 0
        pcdwate = 0
        totwate = 0
        fcdbest = 0
        pcdbest = 0
        fcdfail = 0
        pcdfail = 0
        fcdruns = 0
        pcdruns = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          g = RandomGraph.new(i, (i*k).to_i)
          links += g.edges.length
          fcd_sim = FCDRedSimulator.new(g)
          pcd_sim = PCDAllSimulator.new(g)
          [fcd_sim, pcd_sim].each do |k|
            k.set
          end
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
          puts "fcdsim"
          a,b,q = runsim fcd_sim, 500
          puts "pcdsim"
          c,d,r = runsim pcd_sim, 500
          fcdwate += a
          fcdfail = q
          pcdwate += c
          pcdfail = r
          fcdruns = b
          pcdruns = d
          m = [a,c].select{|k| k > 0}.max 
          if m == a then fcdbest += 1 end
          if m == c then pcdbest += 1 end
        end
        fcdwate = fcdwate / x.to_f
        pcdwate = pcdwate / x.to_f        
#        fcdruns = fcdruns / (x - fcdfail).to_f
#        pcdruns = pcdruns / (x - pcdfail).to_f
#        mtcruns = mtcruns / (x - mtcfail).to_f
        nodes = i
        links = links / x.to_f
        
        @average.push([nodes, links, fcdwate, pcdwate])
        @frequency.push([nodes, links, fcdbest, pcdbest,x])
        @runs.push([nodes, links, fcdruns, pcdruns])
        @fails.push([nodes, links, fcdfail, pcdfail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment7b_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7b_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7b_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7b_fa.tab", 'w') {|x|
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
