$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'sim'
require 'globals'
class Experiment

  def initialize
    @values = [["nodes", "links", "max", "min","average"]]
    Globals.new()
  end
  
  def experiment x
    [120, 1200, 12000,120000].each do |y|
      [1.5,3,6,12].each do |z|
        nodes = 0
        links = 0
        avg = 0
        max = []
        min = []
        x.times do
          $stdout.flush
          u = RandomGraph.new(y, (y*z).to_i)
          links += u.edges.length
          max.push(u.get_max_degree)
          min.push(u.get_min_degree)
          avg += u.get_avg_degree
        end
        
        nodes = y
        links = z*2
        @values.push([nodes, links,max.max,min.min,avg/x])
      end
    end
  end
  
  def print_to_file
    File.open("experiment8d.tab", 'w') {|x|
      @values.each_index do |k|
        s = String.new
        @values[k].each_index do |i|
          s << @values[k][i].to_s + ?\t
        end
        x.puts(s)
      end
    }
  end
end    

x = Experiment.new
x.experiment 2
x.print_to_file
