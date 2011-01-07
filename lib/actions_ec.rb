module EcActs
  def do_next
    @now = @next
    case @now
    when :invite
      @next = :wait
    when :respond
      @next = :update
    when :listen
      @next = :respond
      return true
    when :wait
      @next = :update
      return true
    when :update
      update_colors
      @next = :exchange
    when :exchange
      update_edges
      @next = :choose
    when :choose
      choose_role
    when :done
      @next = :done
    end
  end
end

module Ec_Deciders
  def choose_role
    if criteria_fulfilled then 
      @next = :done
    else
      @next = [:invite, :listen].sample
    end
  end

  def criteria_fulfilled
    !@edges.collect{|k| k.color}.include?(nil)
  end

  def update_colors
  end

  def update_edges
  end
end
