$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'

class Experiment

  def initialize
    @frequency = [["nodes", "links", "pst", "pcd", "total"]]
    @average = [["nodes", "links", "pst", "pcd"]]
    @runs = [["nodes", "links", "pst", "pcd"]]
    @fails = [["nodes", "links", "pst", "pcd"]]
  end
  
  def experiment x
    [30].each do |i|
      [1, 1.5, 3].each do |k|
        pstwate = 0
        pcdwate = 0
        totwate = 0
        pstbest = 0
        pcdbest = 0
        pstfail = 0
        pcdfail = 0
        pstruns = 0
        pcdruns = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          g = RandomGraph.new(i, (i*k).to_i)
          low = g.get_lower_bound
          links += g.edges.length
          pst_sim = PCDSteppingSimulator.new(g)
          pcd_sim = PCDAllSimulator.new(g)
          [pst_sim, pcd_sim].each do |k|
            k.set
          end
          def runsim which, long
            life, runs, fails = which.long_sim 
            return life, runs, fails
          end
          puts "pstsim"
          a,b,q = runsim pst_sim, 500
          puts "pcdsim"
          c,d,r = runsim pcd_sim, 500
          pstwate += a
          pstfail += q
          pcdwate += c 
          pcdfail += r
          pstruns = b
          pcdruns = d
          a == c ? m = 2.1 : m = [a,c].select{|k| k > 0}.max
          if m == a then pstbest += 1 unless a > low end
          if m == c then pcdbest += 1 unless c > low end
          if m > low then puts "something is wrong deeps best = #{a>c} a:#{a}, c:#{c}, low:#{low}" end
        end
        pstwate = pstwate / x.to_f
        pcdwate = pcdwate / x.to_f        
#        pstruns = pstruns / (x - pstfail).to_f
#        pcdruns = pcdruns / (x - pcdfail).to_f
#        mtcruns = mtcruns / (x - mtcfail).to_f
        nodes = i
        links = links / x.to_f
        
        @average.push([nodes, links, pstwate, pcdwate])
        @frequency.push([nodes, links, pstbest, pcdbest,x])
        @runs.push([nodes, links, pstruns, pcdruns])
        @fails.push([nodes, links, pstfail, pcdfail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment7d_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7d_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7d_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7d_fa.tab", 'w') {|x|
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
