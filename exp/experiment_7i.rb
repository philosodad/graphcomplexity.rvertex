$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'
require 'globals'
class Experiment

  def initialize
    @frequency = [["nodes", "links", "mat", "dep", "total"]]
    @average = [["nodes", "links", "mat", "dep"]]
    @runs = [["nodes", "links", "mat", "dep"]]
    @fails = [["nodes", "links", "mat", "dep"]]
    Globals.new()
  end
  
  def experiment x
    [30].each do |i|
      [1, 1.5, 3].each do |k|
        matwate = 0
        depwate = 0
        totwate = 0
        matbest = 0
        depbest = 0
        matfail = 0
        depfail = 0
        matruns = 0
        depruns = 0
        nodes = 0
        links = 0
        x.times do
          $stdout.flush
          g = RandomGraph.new(i, (i*k).to_i)
          low = g.get_lower_bound
          links += g.edges.length
          mat_sim = MatchStepSimulator.new(g)
          dep_sim = DeepsSimulator.new(g)
          [mat_sim, dep_sim].each do |k|
            k.set
          end
          def runsim which, long
            life, runs, fails = which.long_sim 
            return life, runs, fails
          end
          puts "drmsim"
          a,b,q = runsim mat_sim, 500
          puts "depsim"
          c,d,r = runsim dep_sim, 500
          matwate += a
          matfail += q
          depwate += c 
          depfail += r
          matruns = b
          depruns = d
          a == c ? m = 2.1 : m = [a,c].select{|k| k > 0}.max
          if m == a then matbest += 1 unless a > low end
          if m == c then depbest += 1 unless c > low end
          if m > low then puts "something is wrong deeps best = #{a>c} a:#{a}, c:#{c}, low:#{low}" end
        end
        matwate = matwate / x.to_f
        depwate = depwate / x.to_f        
#        matruns = matruns / (x - matfail).to_f
#        depruns = depruns / (x - depfail).to_f
#        mtcruns = mtcruns / (x - mtcfail).to_f
        nodes = i
        links = links / x.to_f
        
        @average.push([nodes, links, matwate, depwate])
        @frequency.push([nodes, links, matbest, depbest,x])
        @runs.push([nodes, links, matruns, depruns])
        @fails.push([nodes, links, matfail, depfail])
      end
    end
  end
  
  def print_to_file
    File.open("experiment7i_av.tab", 'w') {|x|
      @average.each_index do |k|
        s = String.new
        @average[k].each_index do |i|
          s << @average[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7i_fr.tab", 'w') {|x|
      @frequency.each_index do |k|
        s = String.new
        @frequency[k].each_index do |i|
          s << @frequency[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7i_rn.tab", 'w') {|x|
      @runs.each_index do |k|
        s = String.new
        @runs[k].each_index do |i|
          s << @runs[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
    File.open("experiment7i_fa.tab", 'w') {|x|
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
