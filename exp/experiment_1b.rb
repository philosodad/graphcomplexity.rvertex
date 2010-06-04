$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'

class Experiment
  def initialize
    @gg
    @mg
    @table = []
  end

  def experiment
    [10,20,40].each do |i| 
      gweight = 0
      mweight = 0
      tweight = 0
      20.times do
        @gg = DegreeWeightSimulator.new(i, 2)
        @mg = MatchSimulator.new(@gg.rg)
        [@gg, @mg].each{|k| k.set}
        @gg.set_covers
        [@gg, @mg].each{|k| k.sim}
        gweight += @gg.get_on_weight
        mweight += @mg.get_on_weight
        tweight += @mg.get_total_weight
        @gg = nil
        @mg = nil
      end
      gweight = gweight/20.0
      mweight = mweight/20.0
      tweight = tweight/20.0
      @table.push([i, gweight, mweight, tweight])
    end
  end

  def print_to_file
    File.open("exp1_b.csv", 'w') {|x|
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


      
