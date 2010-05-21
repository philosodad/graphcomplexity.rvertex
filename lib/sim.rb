require 'netgen'

class RandomSimulator
  attr_reader :rg, :id
  @@id = 0
  def initialize(n,e)
    @rg = RandomGraph.new(n,e)
    @lock = Mutex.new
    @id = @@id
    @@id += 1
  end

  def set
    @rg.nodes.each{|k| k.set_edges}
#    puts "#{@id}:set"
  end

  def set_covers
    threads = []
    @rg.nodes.each do |k|
      threads << Thread.new(k) do |j|
        j.set_covers
       # puts "\n#{@id}: #{j.id} thread finished"
      end
    end
    threads.each{|t| t.join}
  end

  def sim
    g = 0
    @rg.nodes.each{|k| k.send_initial}
  #  puts "\n #{@id}: continues"
    until g > 500 or allon
      @rg.nodes.each{|k| k.do_next}
      @rg.nodes.each{|k| k.send_status}
      g += 1
    end
    s = String.new()
    puts g
    # @rg.nodes.each{|k| s = s + "#{@id}:#{k.id}.now:#{k.now}; "}
    #puts s
    return g
  end

  def allon
    @rg.nodes.each do |k|
      if k.on == nil
        return false
      end
    end
    return true
  end
  def allcontinue
    @rg.nodes.each do |k|
      if k.now != :continue
        return false
      end
    end
    return true
  end

  def getOnWeight
    return @rg.getOnWeight
  end

  def getInverseWeight
    return @rg.getInverseWeight
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
    @lock = Mutex.new
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
    @rg.setNeighbors
    @rg.nodes.each{|k| k.set_edges}
  end
end

class GridSimulator < RandomSimulator
  def initialize(n,m)
    @rg = GridGraph.new(n,m)
    @id = @@id
    @@id += 1
  end
end
