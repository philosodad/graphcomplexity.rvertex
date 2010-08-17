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
    [50, 150].each do |i| 
      [1.5,3,5].each do |k|
        200.times do
          @rg = RandomGraph.new(i, (i*k).to_i)
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


      
