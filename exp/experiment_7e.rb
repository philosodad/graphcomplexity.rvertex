$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'

class Experiment

  def initialize
    @frequency = [["nodes", "links", "psm", "pcd", "total"]]
    @average = [["nodes", "links", "psm", "pcd"]]
    @runs = [["nodes", "links", "psm", "pcd"]]
    @fails = [["nodes", "links", "psm", "pcd"]]
  end
  
  def experiment x
    [30].each do |i|
      [1, 1.5, 3].each do |k|
        psmwate = 0
        pcdwate = 0
        totwate = 0
        psmbest = 0
        pcdbest = 0
        psmfail = 0
        pcdfail = 0
        psmruns = 0
        pcdruns = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          g = RandomGraph.new(i, (i*k).to_i)
          low = g.get_lower_bound
          links += g.edges.length
          psm_sim = PCDSumSimulator.new(g)
          pcd_sim = PCDAllSimulator.new(g)
          [psm_sim, pcd_sim].each do |k|
            k.set
          end
          def runsim which, long
            life, runs, fails = which.long_sim 
            return life, runs, fails
          end
          puts "psmsim"
          a,b,q = runsim psm_sim, 500
          puts "pcdsim"
          c,d,r = runsim pcd_sim, 500
          psmwate += a
          psmfail += q
          pcdwate += c 
          pcdfail += r
          psmruns = b
          pcdruns = d
          a == c ? m = 2.1 : m = [a,c].select{|k| k > 0}.max
          if m == a then psmbest += 1 unless a > low end
          if m == c then pcdbest += 1 unless c > low end
          if m > low then puts "something is wrong deeps best = #{a>c} a:#{a}, c:#{c}, low:#{low}" end
        end
        psmwate = psmwate / x.to_f
        pcdwate = pcdwate / x.to_f        
#        psmruns = psmruns / (x - psmfail).to_f
#        pcdruns = pcdruns / (x - pcdfail).to_f
#        mtcruns = mtcruns / (x - mtcfail).to_f
        nodes = i
        links = links / x.to_f
        
        @average.push([nodes, links, psmwate, pcdwate])
        @frequency.push([nodes, links, psmbest, pcdbest,x])
        @runs.push([nodes, links, psmruns, pcdruns])
        @fails.push([nodes, links, psmfail, pcdfail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment7e_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7e_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7e_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7e_fa.tab", 'w') {|x|
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
