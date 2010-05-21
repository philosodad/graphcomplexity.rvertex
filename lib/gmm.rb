

module GMM
  
end

module DGMM
  def choose_role
    @invites = []
    if @on != nil then
      @next = :done
    elsif @edges.to_a.select{|k| k.weight == nil}.empty?
      @on = false
      @next = :done
    elsif rand(2) == 1 then
      @next = :invite
    else
      @next = :listen
    end
    return @next
  end

  def choose_edge
    eligible = @edges.to_a.select{|k| k.weight == nil}
    if eligible.length == 0 then return :empty end
    return eligible[rand(eligible.length)]
  end

  def update_edges
    if @on
      @edges.each{|k| if k.weight == nil then k.weight = 0 end}
    else
      ons = @neighbors.select{|k| k.on == true}
      ons.each do |k|
        @edges.each do |j| 
          if j.uv.include?(k.id) and j.weight == nil then j.weight = 0 end
        end
      end
    end
  end

  def update_weight
    if @subtract == 0 then return true end
    edge = @edges.select{|k| k.uv.include?(@rp.id)}.first
    edge.weight = @subtract
    if check_battery == 0 then @on = true end
  end

  def add_invite id
    @invites.push(id)
  end

  def check_battery
    e = @edges.collect{|k| k.weight}.compact.inject(0){|u,v| u+v}
    return 100-(@weight + e)
  end

end

module DGMM_min
  def choose_role
    @invites = []
    if @on != nil then
      @next = :done
    elsif @edges.to_a.select{|k| k.weight == nil}.empty?
      @on = false
      @next = :done
    elsif rand(2) == 1 then
      @next = :invite
    else
      @next = :listen
    end
    return @next
  end

  def choose_edge
    eligible = @edges.to_a.select{|k| k.weight == nil}
    if eligible.length == 0 then return :empty end
    return eligible[rand(eligible.length)]
  end

  def update_edges
    if @on
      @edges.each{|k| if k.weight == nil then k.weight = 0 end}
    else
      ons = @neighbors.select{|k| k.on == true}
      ons.each do |k|
        @edges.each do |j| 
          if j.uv.include?(k.id) and j.weight == nil then j.weight = 0 end
        end
      end
    end
  end

  def update_weight
    if @subtract == 0 then return true end
    edge = @edges.select{|k| k.uv.include?(@rp.id)}.first
    edge.weight = @subtract
    if check_battery == 0 then @on = true end
  end

  def add_invite id
    @invites.push(id)
  end

  def check_battery
    e = @edges.collect{|k| k.weight}.compact.inject(0){|u,v| u+v}
    return @weight - e
  end

end
