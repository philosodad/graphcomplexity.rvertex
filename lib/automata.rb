#assumptions: the module is being used by a class that has both an @on (boolean) and @covers (LdGraph) variable @currentcover

module BasicAutomata
  def transition(id, status)
    @onlist[id] = status
    update_covers_on
    curcov = @covers.ldnodes[@currentcover]
    if curcov.has?(id) and !status
#      @currentcover = (@currentcover+1)%(@covers.ldnodes.length)
#      return transition(id, status)
      return :change_cover
    elsif !curcov.has?(id) and status
#      @currentcover = (@currentcover+1)%(@covers.ldnodes.length)
#      return transition(id, status)
      return :change_cover
    else
      return :analyze    
    end
  end

  def highest_priority?
    start = -1
    notons = []
    notons = @covers.ldnodes[@currentcover].cover.select{|k| @onlist[k] != true} unless @covers.ldnodes[@currentcover] == nil
    notonweights = @keyedweights.select{|k| notons.include?(k)}
    if notonweights.values.max == @weight
      return true
    elsif notons.min == @id
      return true
    elsif @round > notons.length
      if rand(notons.length) == 0
        return true
      end
    end
    return false    
  end

  def out_of_cover?
    return !@covers.ldnodes[@currentcover].has?(@id) unless @covers.ldnodes[@currentcover] == nil
    return true
  end
  
  def any_off?
    c = @covers.ldnodes[@currentcover].cover
    c.each{|k| if @onlist[k] == false then return true end}
    return false
  end

  def any_covered?
    @covers.ldnodes.each_index do |k|
      if covered? k then 
        return true 
      end
    end
    return false
  end

  def covered? *args
    if args.empty?
      c = @covers.ldnodes[@currentcover].cover
      c.each{|k| if @onlist[k] != true then return false end}
      return true
    else 
      cc = args[0]
      c = @covers.ldnodes[cc].cover
      c.each{|k| if @onlist[k] != true then return false end}
      return true
    end
  end
end
