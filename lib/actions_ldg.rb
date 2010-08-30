module LDG_Standard_Acts
  def do_next
    curcov = @covers.ldnodes[@currentcover]
    if curcov == nil then
      sort_covers
      @currentcover = 0
    end
    if @covers.ldnodes.length == 0 then
      puts "#{@id} has no remaining covers"
    end
    @now = @next
    case @now
    when :analyze
      if highest_priority? then
        @on = true
        @onlist[@id] = true
        @now = :sendon
        @next = :done
      elsif out_of_cover? and covered? and @on == nil
        @on = false
        @onlist[@id] = false
        @now = :sendoff
        @next = :done
      elsif @on != nil
        @next = :analyze
      end
    when :change_cover
      @currentcover += 1
      @currentcover = @currentcover%@covers.ldnodes.length
      @next = :analyze
    when :out_of_batt
      @next = :out_of_batt
    end
    @round += 1
  end
  
  def send_status
    case @now
    when :sendon, :sendoff
      @neighbors.each{|k| k.recieve_status(@id, @on)}
    end
  end
  
  def recieve_status id, status
    @next = transition id, status unless @on != nil
  end  
end

module LDG_Red_Acts
def do_next
    curcov = @covers.ldnodes[@currentcover]
    if curcov == nil then
      sort_covers
      @currentcover = 0
    end
    if @covers.ldnodes.length == 0 then
      puts "#{@id} has no remaining covers"
    end
    @now = @next
    case @now
    when :analyze
      if highest_priority? then
        @on = true
        @onlist[@id] = true
        @now = :sendon
        @next = :decided
      elsif out_of_cover? and covered? and @on == nil
        @on = false
        @onlist[@id] = false
        @now = :sendoff
        @next = :decided
      elsif @on != nil
        @next = :analyze
      end
    when :change_cover
      @currentcover += 1
      @currentcover = @currentcover%@covers.ldnodes.length
      @next = :analyze
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    when :out_of_batt
      @next = :out_of_batt
    end
    @round += 1
  end
  
  def send_status
    case @now
    when :sendon, :sendoff
      @neighbors.each{|k| k.recieve_status(@id, @on)}
    end
  end
  
  def recieve_status id, status
    @next = transition id, status unless @on != nil
  end  
end

module LDG_Cover_Acts
  def set_covers
    @covers = build_covers unless @edges.empty?
  end

  def burn_cover node
    @covers.burn_cover node
  end

  def update_covers_on
    @covers.ldnodes.each do |k|
      k.onremain = k.cover.length
      k.cover.each{|j| if @onlist[j] == true then k.onremain -= 1 end}
    end
  end

  def sort_covers
    @covers.ldnodes.each{|k| k.set_onremain(@neighbors + [self])}
    @covers.ldnodes.sort!
  end
end
