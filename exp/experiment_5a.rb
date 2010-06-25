$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'

class Experiment
  def initialize
    @gg
    @mg
    @table = [["size","star","match","total"]]
  end

  def experiment
    [10,20].each do |i| 
      wweight = 0
      mweight = 0
      tweight = 0
      wrounds = 0
      20.times do
        @gg = GridGraph.new(i, 2)
        @mg = MatchSimulator.new(@gg)
        @wg = StarSimulator.new(@gg)
        [@wg, @mg].each{|k| k.set}
        [@wg, @mg].each{|k| k.sim}
        if @wg.rg.covered?
          wweight += @wg.get_on_weight
          wrounds += 1
        end
        mweight += @mg.get_on_weight
        tweight += @mg.get_total_weight
        @gg = nil
        @mg = nil
      end
      wweight = wweight/wrounds.to_f unless wrounds == 0
      mweight = mweight/20.0
      tweight = tweight/20.0
      @table.push([i, wweight, mweight, tweight])
    end
  end

  def print_to_file
    File.open("exp5_a.tab", 'w') {|x|
      @table.each_index do |k|
        s = String.new
        @table[k].each_index do |i|
          s << @table[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
  end
end

x = Experiment.new
x.experiment
x.print_to_file


      
