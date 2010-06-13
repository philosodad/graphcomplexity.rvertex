require 'netgen'

class RandomSimulator
  attr_reader :rg, :id
  @@id = 0
  def initialize(n,e)
    @rg = RandomGraph.new(n,e)
    @id = @@id
    @@id += 1
  end

  def set
    @rg.nodes.each{|k| k.set_edges}
  end

  def set_covers
    threads = []
    @rg.nodes.each do |k|
      threads << Thread.new(k) do |j|
        j.set_covers
      end
    end
    threads.each{|t| t.join}
  end

  def long_sim
    while @rg.coverable? do
      sim
      p @rg.nodes.select{|k| k.on}.collect{|j| j.id}
      @rg.reduce_by_min
      @rg.nodes.each do |k| 
        if k.weight == 0 then 
          k.on = false
          k.set_next(:out_of_batt)
          k.neighbors.each{|j| j.burn_cover(k)}
        else
          k.on = nil
          k.set_next(:analyze)
        end
      end
    end
  end
        
  def sim
    g = 0
    until g > 800 or @rg.covered?
      threads = []
      @rg.nodes.each do |k|
        threads << Thread.new(k) do |j|
          j.do_next
        end
      end
      threads.each{|t| t.join}
      threads = []
      @rg.nodes.each do |k|
        threads << Thread.new(k) do |j|
          j.send_status
        end
      end
      threads.each{|t| t.join}
      g += 1
    end
    puts g
    return g
  end

  def all_on
    @rg.nodes.each do |k|
      if k.on == nil
        return false
      end
    end
    return true
  end

  def all_continue
    @rg.nodes.each do |k|
      if k.now != :continue
        return false
      end
    end
    return true
  end

  def get_on_weight
    return @rg.get_on_weight
  end

  def get_inverse_weight
    return @rg.get_inverse_weight
  end

  def get_total_weight
    return @rg.get_total_weight
  end

  def zero_out
    @@id = 0
  end
end

class UDGSimulator < RandomSimulator
  def initialize(n, d, s)
    @rg = UnitDiskGraph.new(n,d,s)
    @id = @@id
    @@id += 1
  end
end

class SetSimulator < RandomSimulator
  def initialize(g)
    @rg = g
    @id = @@id
    @@id += 1
  end
end

class MatchSimulator < RandomSimulator
  def initialize(g)
    @rg = MatchGraph.new(g)
    @id = @@id
    @@id += 1
  end

  def long_sim
    while @rg.coverable?
      sim
      p @rg.nodes.select{|k| k.on}.collect{|j| j.id}
      p @rg.nodes.collect{|k| k.class}
      @rg.reduce_by_min
      puts "hey"
      @rg.nodes.each do |k|
        k.edges.each{|j| j.weight = nil}
        k.on = nil
        k.set_next :choose
      end
      p @rg.nodes.collect{|k| k.weight}
    end
  end

  def sim
    g = 0
    until all_done or g > 500
      @rg.nodes.each{|k| k.do_next}
      @rg.nodes.each{|k| k.send_status}
      g+=1
    end
    puts g
    return g
  end
  def all_done
    return @rg.nodes.select{|k| k.now != :done}.empty?
  end

  def set
    @rg.nodes.each{|k| k.set_edges}
  end
end

class MatchMaxSimulator < MatchSimulator
  def initialize(g)
    @rg = MatchMaxGraph.new(g)
    @id = @@id
    @@id +=1
  end
end

class GridSimulator < RandomSimulator
  def initialize(n,m)
    @rg = GridGraph.new(n,m)
    @id = @@id
    @@id += 1
  end
end

class TotalWeightSimulator < RandomSimulator
  def initialize(n,m)
    @rg = TotalWeightGraph.new(n,m)
    @id = @@id
    @@id += 1
  end
end

class DegreeWeightSimulator < RandomSimulator
  def initialize(n,m)
    @rg = DegreeWeightGraph.new(n,m)
    @id = @@id
    @@id += 1
  end
end

