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
      glife = 0
      mlife = 0
      10.times do
        @gg = GridSimulator.new(i, 2)
        @mg = MatchSimulator.new(@gg.rg)
        [@gg, @mg].each{|k| k.set}
        @gg.set_covers
        glife += @gg.long_sim
        mlife += @mg.long_sim
        @gg = nil
        @mg = nil
      end
      glife = glife/10.0
      mlife = mlife/10.0
      @table.push([i, glife, mlife])
    end
  end

  def print_to_file
    File.open("exp3_a.csv", 'w') {|x|
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
