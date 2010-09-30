$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'

class Experiment
  def initialize
    @gg
    @mg
    @table = []
  end

  def experiment
    [10,20].each do |i| 
      wlife = 0
      mlife = 0
      10.times do
        @gg = GridGraph.new(i, 2)
        @wg = MatchMWMSimulator.new(@gg)
        @mg = MatchSimulator.new(@gg)
        [@mg, @wg].each{|k| k.set}
        wlife += @wg.long_sim
        mlife += @mg.long_sim
        @gg = nil
        @wg = nil
        @mg = nil
      end
      wlife = wlife/10.0
      mlife = mlife/10.0
      @table.push([i, wlife, mlife])
    end
  end

  def print_to_file
    File.open("exp3_b.csv", 'w') {|x|
      @table.each_index do |k|
        s = String.new
        @table[k].each_index do |i|
          s << @table[k][i].to_s + ','
        end
        x.puts(s)
      end
    }
  end
  
end

x = Experiment.new
x.experiment
x.print_to_file
