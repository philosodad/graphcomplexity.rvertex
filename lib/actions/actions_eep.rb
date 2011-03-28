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
    when :covertargets
      @on = false
      @alert_list = []
      @next = :get_weights
    when :get_weights
      @next = :alert_neighbors
    when :alert_neighbors
      filter_alerts
      @next = :done
    when :send_weight
      @next = :get_alert
    when :get_alert
      @next = :done
    end
  end

  def send_status
    case @now
    when :boot, :poor, :hills, :sinks, :charge
      @now = @now
    when :covertargets
      @neighbors.each{|k| k.alert} 
    when :alert_neighbors
      @alert_list.each{|k| k.recieve_status(true)}
    when :send_weight
      @neighbors.each{|k| k.recieve_status(self)}
    else
      @neighbors.each{|k| k.recieve_status(@id, @on)}
    end
  end

  def recieve_status *args
    case args.length
    when 2
      id = args[0]
      on = args[1]
      if on == true
        @offlist.delete(id)
        @onlist.push(id)
      elsif on == false
        @onlist.delete(id)
        @offlist.push(id)
      end
      @onlist.uniq!
      @offlist.uniq!
    when 1
      case @now
      when :get_weights
         @alert_list.push(args[0])
      when :get_alert
        @on = args[0]
      end
    end
  end

  def alert
    if @weight > 0
      @next = :send_weight
    end
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
    begin
      @poorest = @edges.min
      @poorest.type = :sink
    rescue => ex
      p "#{ex.class}: cannot find the poorest edge"
    end
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
      (@poorest.nodes - [self]).select{|k| k.poorest == @poorest and k > self}.any? ? return : @charges.push(@poorest)
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
    @edges.select{|k| (k.nodes - [self]).select{|j| !j.off?}.empty?}.any?
  end
  
  def charges_covered?
    @on == true or @charges.select{|k| (k.nodes - [self]).select{|j| j.on}.empty?}.empty? 
  end

  def filter_alerts
    alerts = []
    @edges.select{|k| (k.ids & @onlist).empty?}.each do |k|
      if (k.ids & alerts.collect{|k| k.id}).empty? then
        alerts.push(@alert_list.select{|j| k.ids.include?(j.id)}.max)
      end
    end
    @alert_list = alerts.compact
  end
end
