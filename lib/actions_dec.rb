module Dec_Acts
 def do_next
    @now = @next
    case @now
    when :invite
      choose_round_partner
      @next = :wait
    when :respond
      evaluate_invites
      @next = :attend
    when :listen
      @next = :respond
    when :wait
      @next = :certify
    when :certify
      @next = :update
    when :attend
      @next = :update
    when :update
      update_edges
      @next = :exchange
    when :exchange
      update_colors
      @next = criteria_fulfilled? ? :done : :choose
    when :choose
      choose_role
    when :done
      @next = :done
    end
  end
end

module Dec_Deciders

  def choose_role
    if @deadcolors == nil or @deadcolors == {}
      @deadcolors = {}
      @neighbors.each{|k| @deadcolors[k.id] = []}
    end

    if criteria_fulfilled? then 
      @next = :done
    else
      @next = [:invite, :listen].sample
    end
  end

  def evaluate_invites
    my_inv = @invites.select{|k| k.to == @id}
    ot_inv = @invites.reject{|k| k.to == @id}
    free_colors = (my_inv.collect{|k| k.data} - ot_inv.collect{|k| k.data}).uniq
    inv = my_inv.select{|k| free_colors.include?(k.data)}.sample
    if inv
      @rp = @neighbors.select{|k| k.id == inv.from}
      @next_message = Message.new(@id, @rp.id, inv.data)
    end
  end

  def update_edges
  end

  def update_colors
  end

  def criteria_fulfilled?
    !@edges.collect{|k| k.criteria}.collect{|k| k.values}.flatten.include?(nil)
  end

end
