#assumptions: the module is being used by a class that has both an @on (boolean) and @covers (LdGraph) variable @currentcover

module BasicAutomata
  def transition(id, status)
    curcov = @covers.ldnodes[@currentcover]
    if !curcov.has?(id) and !status
      return :continue
    elsif curcov.has?(@id) and 
        curcov.onremain == 1 and 
        !@on then
      @on = true
      return :sendon
    elsif !curcov.has?(@id) and
        curcov.onremain == 0 then
      @on = false
      return :sendoff
    elsif curcov.has?(id) and !status 
      @currentcover = (@currentcover+1)%@covers.ldnodes.length
      return transition(id, status)
    elsif !curcov.has?(id) and status
      sort_covers
      if curcov.has?(@id)
        if @on then
          return true
        else
          @on = true
          return :sendon
        end
      else
        if @on then
          @on = false
          return :sendoff
        else
          return true
        end
      end
    else
      return true
    end
  end     
end
