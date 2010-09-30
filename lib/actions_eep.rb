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
  end
end


module DeepsDeciders
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
    @edges.each{|k| if k.type == nil then k.type = :hill end}
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
    @charges.each do |k|
      if !@onlist.include? k.v.id then return false end
      if @offlist.include? k.v.id then return false end
    end
    ret = nil
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
    if @offlist.empty? then return false end
    return true
  end
end
