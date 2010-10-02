require 'netgen_pcd'
require 'netgen_star'
require 'netgen_dumb'
require 'netgen_fcd'
require 'netgen_eep'
require 'helpers_sim'

class RandomSimulator
  include Sim_To_Done
  include Running_Sim
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
        
=begin  def sim
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
#    puts "#{@id} g: #{g}"
    return g
=end  end

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

class RandomRedSimulator < RandomSimulator
  def initialize(g)
    @rg = RandomGraphRed.new(g)
    @id = @@id
    @@id += 1
  end
end

class RandomShortRedSimulator < RandomSimulator
  def initialize(g)
    @rg = RandomGraphShort.new(g)
    @id = @@id
    @@id += 1
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

class DumbRedSimulator < RandomSimulator
  include Sim_To_Done
  def initialize(g)
    @rg = DumbRedGraph.new(g)
    @id = @@id
    @@id += 1
  end
end

class DeepsSimulator < RandomSimulator
  include Sim_To_Done
  include Stepping_Sim
  def initialize(g)
    @rg = DeepsGraph.new(g)
    set_id
  end
  
  def set_id
    @id = @@id
    @@id +=1
  end

  def set
    @rg.nodes.each{|k| k.set_edges}
  end
    
end
  
class DeepsRedMinSimulator < RandomSimulator
  def initialize(g)
    @rg = DeepsRedMinGraph.new(g)
    @id = @@id
    @@id += 1
  end
end

class DeepsMinMinSimulator < DeepsSimulator
  def initialize(g)
    @rg = DeepsMinMinGraph.new(g)
    set_id
  end
end

class DeepsMaxMaxSimulator < DeepsSimulator
  def initialize(g)
    @rg = DeepsMinMinGraph.new(g)
    set_id
  end
end

class DeepsMinMaxSimulator < DeepsSimulator
  def initialize(g)
    @rg = DeepsMinMinGraph.new(g)
    set_id
  end
end

class FCDRedSimulator < RandomSimulator
  include Sim_To_Done
  def initialize(g)
    @rg = FCDRedGraph.new(g)
    @rg.nodes.each{|k| k.set_edges}
    @id = @@id
    @@id +=1
  end

  def set
    @rg.nodes.each{|k| k.set_covers}
  end
end

class PCDSimulator < RandomSimulator
  include Sim_To_Done
  def initialize(g)
    @rg = PCDGraph.new(g)
    @id = @@id
    @@id += 1
  end

  def set
    @rg.nodes.each{|k| k.build_first_cover}
    @rg.nodes.each{|k| k.get_covers}
    @rg.nodes.each{|k| k.covers.set_edges}
    @rg.nodes.each{|k| k.covers.set_degrees}
  end

end


class PCDDeltaSimulator < PCDSimulator
  def initialize(g)
    @rg = PCDDeltaGraph.new(g)
    @id = @@id
    @@id +=1
  end
end

class PCDAllSimulator < PCDSimulator
  def initialize(g)
    @rg = PCDAllGraph.new(g)
    @id = @@id
    @@id +=1
  end

  def set
    @rg.nodes.each{|k| k.build_local_cover}
    @rg.nodes.each{|k| k.get_covers}
    @rg.nodes.each{|k| k.covers.set_edges}
    @rg.nodes.each{|k| k.covers.set_degrees}
  end
end

class PCDSumSimulator < PCDAllSimulator
  def initialize(g)
    @rg = PCDAllGraphSum.new(g)
    @id = @@id
    @@id += 1
  end
end

class PCDMinRedSimulator < PCDAllSimulator
  def initialize(g)
    @rg = PCDMinRedGraph.new(g)
    @id = @@id
    @@id +=1
  end
end

class PCDSteppingSimulator < PCDAllSimulator
  include Stepping_Sim
end

class PCDAllSimulatorNoRed < PCDAllSimulator
  def initialize(g)
    @rg = PCDAllGraphNoRed.new(g)
    @id = @@id
    @@id += 1
  end
end

class MatchSimulator < RandomSimulator
  include Sim_To_Done
  def initialize(g)
    @rg = MatchGraph.new(g)
    @id = @@id
    @@id += 1
  end

=begin  def long_sim
    t = 0
    while @rg.coverable?
      sim
      t += @rg.reduce_by_min
      @rg.nodes.each do |k|
        k.reset
      end
    end
    puts "#{@id} t: #{t}"
    return t
=end  end

  def set
    @rg.nodes.each{|k| k.set_edges}
  end
end

class MatchStepSimulator < MatchSimulator
  include Stepping_Sim
end

class MatchMaxSimulator < MatchSimulator
  def initialize(g)
    @rg = MatchMaxGraph.new(g)
    @id = @@id
    @@id +=1
  end
end

class MatchMWMSimulator < MatchSimulator
  def initialize(g)
    @rg = MatchMWMGraph.new(g)
    @id = @@id
    @@id +=1
  end
end

class MatchRedSimulator < MatchSimulator
  def initialize(g)
    @rg = MatchRedGraph.new(g)
    @id = @@id
    @@id += 1
  end
end
  

class StarSimulator < MatchSimulator
  def initialize(g)
    @rg = StarGraph.new(g)
    @id = @@id
    @@id += 1
  end
end

class StarRedSimulator < StarSimulator
  def initialize(g)
    @rg = StarRedGraph.new(g)
    @id = @@id
    @@id += 1
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

