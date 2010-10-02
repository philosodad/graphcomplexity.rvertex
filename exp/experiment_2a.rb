$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'

class Experiment
  def initialize
    @match
    @pcd
    @count = 0
  end

  def experiment
    [20,40,80].each do |i| 
      [3, 7].each do |j|
        20.times do
          rg = RandomGraph.new(i, i*j)
          puts "graphmade"
          @match = MatchSimulator.new(rg)
          @pcd = PCDAllSimulator.new(rg)
          puts "sims made"
          [@match, @pcd].each{|k| k.set}
          puts "sims set"
          [@match, @pcd].each{|k| k.sim}
          puts "simmed"
          a = @match.get_on_weight
          b = @pcd.get_on_weight
          if a > 2*b then @count += 1 end
        end
      end
    end
  end

  def print_to_file
    File.open("exp_2a.tab", 'w') {|x|
      s = @count.to_s
      x.puts(s)
    }
  end
end

x = Experiment.new
x.experiment
x.print_to_file


      
