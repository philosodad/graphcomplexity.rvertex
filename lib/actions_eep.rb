module DeepsActs
  def do_next
    @now = @next
    case @now
    when :boot
      @on = nil
      @charges = []
      @onlist = []
      @offlist = []
      @next = :poor
      @poorest = nil
    when :poor
      find_poorest_edge
      @next = :sinks
    when :sinks
      set_all_sinks
      @next = :hills
    when :hills
      find_hills
      @next = :charge
    when :charge
      set_all_hills
      @next = :analyze
    when :analyze
      if @weight == 0
        @on = false
        @next = :done
      elsif sole_survivor?
        @on = true
        @next = :done
      elsif @charges.empty? or charges_covered?
        @on = false
        @next = :done
      else
        @next = :analyze
      end
    when :done
      @next = :done
    end
  end

  def send_status
    case @now
    when :boot, :poor, :hills, :sinks, :charge
      @now = @now
    else
      @neighbors.each{|k| k.recieve_status(@id, @on)}
    end
  end

  def recieve_status id, on
    if on == true
      @onlist.push(id)
    elsif on == false
      @offlist.push(id)
    end
    @onlist.uniq!
    @offlist.uniq!
  end
end

module DeepsRedActs
  def do_next
    @now = @next
    case @now
    when :boot
      @on = nil
      @charges = []
      @onlist = []
      @offlist = []
      @next = :poor
      @poorest = nil
    when :poor
      find_poorest_edge
      @next = :sinks
    when :sinks
      set_all_sinks
      @next = :hills
    when :hills
      find_hills
      @next = :charge
    when :charge
      set_all_hills
      @next = :analyze
    when :analyze
      if @weight == 0
        @on = false
        @next = :decided
      elsif sole_survivor?
        @on = true
        @next = :decided
      elsif @charges.empty? or charges_covered?
        @on = false
        @next = :decided
      else
        @next = :analyze
      end
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end
end

module Deeps_Deciders
  def set_all_sinks
    if @weight > 0 then
      if @poorest.v.poorest.eql? @poorest       
        @charges.push @poorest if self > @poorest.v
      else
        @charges.push(@poorest)
      end
    end
  end

  def find_hills
    @edges.each do |k| 
      if k.type == nil then k.type = :hill end
      k.nodes.each{|j| if j.poorest == k then k.type = :sink end}
    end
  end

  def set_all_hills
#    puts 'setting all hills'
    @edges.select{|k| k.type == :hill}.each do |j|
      if j.v.weight == 0
        @charges.push j unless @charges.include?(j)
        j.v.charges = []
      elsif @poorest.supply > j.v.poorest.supply then
        @charges.push j unless (@charges.include?(j) or j.v.charges.collect{|l| l.uv}.include?(j.uv))
#        puts 'j added to charges'
      elsif @poorest.supply == j.v.poorest.supply then
        @charges.push j unless (@charges.include?(j) or j.v.charges.collect{|l| l.uv}.include?(j.uv) or j.v > self)
      end
    end
  end
    
  def find_poorest_edge
    @poorest = @edges.min
    @poorest.type = :sink
  end

  def charges_covered?
    ret = false
    @charges.each do |k|
      ret = false
      if k.v.on then 
        ret = true
      else 
        return false
      end
    end
    return ret
  end
  
  def sole_survivor?
    return !(@neighbors.select{|k| k.off?}.empty?)
  end
end

module Deeps_Deciders_Maximize_Max
  include Deeps_Deciders
  def find_poorest_edge
    @poorest = @edges.max
    @poorest.type = :sink
  end
end

module Deeps_Deciders_Minimize_Max
  include Deeps_Deciders_Maximize_Max
  def set_all_sinks
    if @weight > 0 then
      if @poorest.v.poorest.eql? @poorest       
        @charges.push @poorest if self < @poorest.v
      else
        @charges.push(@poorest)
      end
    end
  end

  def find_hills
    @edges.each{|k| if k.type == nil then k.type = :hill end}
  end

  def set_all_hills
#    puts 'setting all hills'
    @edges.select{|k| k.type == :hill}.each do |j|
      if j.v.weight == 0
        @charges.push j unless @charges.include?(j)
        j.v.charges = []
      elsif @poorest.supply < j.v.poorest.supply then
        @charges.push j unless (@charges.include?(j) or j.v.charges.collect{|l| l.uv}.include?(j.uv))
        #        puts 'j added to charges'
      elsif @poorest.supply == j.v.poorest.supply then
        @charges.push j unless (@charges.include?(j) or j.v.charges.collect{|l| l.uv}.include?(j.uv) or j.v < self)
      end
    end
  end
end

module Deeps_Deciders_Minimize_Min
  include Deeps_Deciders_Minimize_Max
  def find_poorest_edge
    @poorest = @edges.min
    @poorest.type = :sink
  end
end

module Hyper_Deeps_Deciders
  include Deeps_Deciders

  def set_all_sinks
    if @weight > 0 then
      nebs = @poorest.nodes - [self]
      nebs.each do |k|
        if k.poorest == @poorest and k > self
          return false
        end
      end
      @charges.push(@poorest)
    end
  end

  def set_all_hills
    @edges.select{|k| k.type == :hill}.each do |j|
      nebs = j.nodes - [self]
      if nebs.collect{|k| k.weight}.reduce(:+) == 0 then
        @charges.push j unless @charges.include?(j)
        nebs.each{|i| i.charges = []}
      elsif nebs.collect{|k| k.poorest.supply}.flatten.max < @poorest.supply
        @charges.push j unless @charges.include?(j)
      elsif @poorest.supply == nebs.collect{|k| k.poorest.supply}.flatten.max
        @charges.push j unless @charges.include?(j) or nebs.max > self
      end
    end
  end

  def sole_survivor?
    @edges.each do |j|
      if (j.ids.to_a - offlist) == [id] then return true end
    end
    false
  end
  
end
