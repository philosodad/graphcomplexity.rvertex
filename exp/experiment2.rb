require 'sim'

class Experiment
  def initialize
    @mg
    @table = []
  end

  def experiment
    [10,20,40, 80].each do |i|
      r = 20
      runs = 0
      max = 0
      min = 50000000
      mg = []
      r.times do
        rg = GridGraph.new(i, 2)
        @mg = MatchSimulator.new(rg)
        mg.push(@mg)
      end
      puts i
      threads = []
      mg.each do |k|
        threads << Thread.new(k) do |t|
          t.set
          run = t.sim
          runs += run
          if run > max then max = run end
          if run < min then min = run end
        end
      end
      threads.each{|t| t.join}
      runs = runs/r.to_f
      @table.push([i, runs, max, min])
    end
  end
  
  def print_to_file
    File.open("exp2.3.csv", 'w') {|x|
    @table.each_index do |k|
      s = String.new
      @table[k].each_index.each do |i|
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


      
