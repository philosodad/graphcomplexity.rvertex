module DeepsActs
  def do_next
    @now = @next
    case @now
    when :boot
      @charges = []
      @onlist = []
      @offlist = []
      @next = :poor
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
      if @charges.empty? or charges_covered?
        @on = false
        @next = :done
      elsif sole_survivor?
        @on = true
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
    when :boot, :poor, :hills, :sinks
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
    @edges.each do |k|
      if k.v.poorest.eql? k       
        @charges.push(k) unless (k.v.charges.collect{|j| j.uv}.include?(k.uv) or @charges.include?(k)) 
      end
    end
  end

  def find_hills
    @edges.each{|k| if k.type == nil then k.type = :hill end}
  end

  def set_all_hills
#    puts 'setting all hills'
    @edges.select{|k| k.type == :hill}.each do |j|
      if @poorest.supply > j.v.poorest.supply then
        @charges.push j unless (@charges.include?(j) or j.v.charges.collect{|l| l.uv}.include?(j.uv))
#        puts 'j added to charges'
      end
    end
  end
    
  def find_poorest_edge
    @poorest = @edges.min
    if @poorest.supply - @weight <= @weight
      @charges.push(@poorest) unless @poorest.v.charges.collect{|k| k.uv}.include?(@poorest.uv)
    end
    @poorest.type = :sink
  end

  def charges_covered?
    @charges.each do |k|
      if !@onlist.include? k.v.id then return false end
      if @offlist.include? k.v.id then return false end
    end
    return true
  end
  
  def sole_survivor?
    if @offlist.empty? then return false end
    return true
  end
end
