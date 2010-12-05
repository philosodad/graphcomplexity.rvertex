module Boat_Acts
  def do_next
    @next = @now
    case @now
    when :choose
      @next = choose_role
    when :search
      @next = :wait
    when :listen
      @next = :reply
    
    end
end
