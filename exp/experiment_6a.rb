$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'

class Experiment
  def initialize
    @rg
    @ag
    @fails = 0
    @attempts = 0
  end

  def experiment
    [500, 1000].each do |i| 
      [4,8,16].each do |k|
        10.times do
          @rg = RandomGraph.new(i, i*k)
          @ag = PCDAllSimulator.new(@rg)
          @fails += @ag.long_sim[2]
          @attempts += 1
        end
        @rg = nil
        @ag = nil
      end
    end
  end

  def print_to_file
    File.open("exp6_a.tab", 'w') {|x|
      s = String.new
      s << "Failure Rate: "
      s << "#{@fails/@attempts}"
      x.puts(s)
    }
  end
end

x = Experiment.new
x.experiment
x.print_to_file


      
