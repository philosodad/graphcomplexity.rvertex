#assumptions: the module is being used by a class that has both an @on (boolean) and @covers (LdGraph) variable @currentcover

module BasicAutomata
  def transition(id, status)
    @onlist[id] = status
    update_covers_on
    curcov = @covers.ldnodes[@currentcover]
    if curcov.has?(@id) and 
        curcov.onremain == 1 and 
        !@on then
      return :sendon
    elsif !curcov.has?(@id) and
        curcov.has?(id) and
        status and
        curcov.onremain == 0 then
      return :sendoff
    elsif !curcov.has?(id) and !status
      return :continue
    elsif curcov.has?(id) and 
        status then
      return :continue
    elsif curcov.has?(id) and !status
      @currentcover = (@currentcover+1)%@covers.ldnodes.length
      return transition(id, status)
    elsif !curcov.has?(id) and status
      @currentcover = (@currentcover+1)%@covers.ldnodes.length
      return transition(id, status)
    else
      return :oddfail    
    end
  end

  def highest_priority curcov
    puts "Hey, I've been Called!"
    if curcov.has?(@id)
      puts "hey, I'm in the cover!"
      puts "noton: #{curcov.cover.to_a.select{|k| @onlist[k] != true}.min}"
      puts "#{@id}"
      a = curcov.cover.to_a.select{|k| @onlist[k] != true}.min
      puts "a:#{a}, id:#{@id}"
      if a == @id then return true end
    end
    return false
  end
end

