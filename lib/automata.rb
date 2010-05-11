#assumptions: the module is being used by a class that has both an @on (boolean) and @covers (LdGraph) variable @currentcover

module BasicAutomata
  def transition(id, status)
    sort_covers
    curcov = @covers.ldnodes[@currentcover]
    if curcov.has?(@id) and 
        curcov.onremain == 1 and 
        !@on then
      return :sendon
    elsif !curcov.has?(@id) and
        curcov.onremain == 0 then
      return :sendoff
    elsif !curcov.has?(id) and !status
      return :continue
    elsif curcov.has?(id) and 
        status
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
end
