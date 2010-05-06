#assumptions: the module is being used by a class that has both an @on (boolean) and @covers (LdGraph) variable @currentcover

module BasicAutomata
  def transition(id, status)
    if !@covers.ldnodes[@currentcover].cover.include?(id) and
        !status
      return true
    elsif @covers.ldnodes[@currentcover].cover.include(@id) and 
        @covers.ldnodes[@currentcover].onremain == 1 and 
        !@on then
      @on = true
      return :sendon
    elsif !@covers.ldnodes[@currentcover].cover.include(@id) and
        @covers.ldnodes[@currentcover].onremain == 0 then
      @on = false
      return :sendoff
    elsif @covers.ldnodes[@currentcover].cover.include?(id) and !status 
      @currentcover = (@currentcover+1)%@covers.ldnodes.length
      return transistion(id, status)
    elsif !@covers.ldnodes[@currentcover].cover.include(id) and status
      return :reshuffle
    else
      return true
    end
  end     
end
