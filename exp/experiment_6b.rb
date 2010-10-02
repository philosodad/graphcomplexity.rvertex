$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'sim'

class Experiment
  def initialize
    @rg = RandomSimulator.new(100, 200)
    puts @rg.rg.coverable?
    @sg
    @mg
    @ag
    @table = [["size","degree","auto","star","match", "pcd","total"]]
  end

  def experiment
    [20, 40].each do |i| 
      [2,4].each do |j|
        rweight = 0
        sweight = 0
        mweight = 0
        aweight = 0
        tweight = 0
        wrounds = 0
        2.times do
          puts "I will make a simulator"
          @rg = RandomSimulator.new(i, i*j)
          @sg = StarRedSimulator.new(@rg.rg)
          @mg = MatchRedSimulator.new(@rg.rg)
          @ag = PCDAllSimulator.new(@rg.rg)
          [@rg, @sg, @mg, @ag].each{|k| k.set}
          puts "I have made simulators!"
          @rg.set_covers
          puts "I have set covers!"
          [@rg, @sg, @mg, @ag].each{|k| k.sim}
          if @sg.rg.covered?
            wrounds += 1
            rweight += @rg.get_on_weight
            sweight += @sg.get_on_weight
            mweight += @mg.get_on_weight
            aweight += @ag.get_on_weight
            tweight += @rg.get_total_weight
          end
          @gg = nil
          @mg = nil
        end
        [rweight, sweight, mweight, aweight, tweight].each do |k|
          k = k/wrounds.to_f unless wrounds == 0
        end
        @table.push([i,j, rweight, sweight, mweight, aweight, tweight])
      end
    end
  end

  def print_to_file
    File.open("exp6_b.tab", 'w') {|x|
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
