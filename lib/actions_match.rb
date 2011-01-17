module Match_Acts
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
      update_weight
      @next = :exchange
    when :exchange
      update_edges
      @next = :choose
    when :choose
      choose_role
    when :done
      @next = :done
    when :out_of_batt
      @next = :out_of_batt
    end
  end

  def send_status
    case @now
    when :invite
      e = choose_edge
      if e == :empty then 
        return true
      else
        i = (e.uv - Set[@id]).first
        @rp = @neighbors.select{|k| k.id == i}.first
        @rp.recieve_status (@id)
      end
    when :respond
      if not @invites.empty? then
        n = @invites[rand(@invites.length)]
        @rp = @neighbors.select{|k| k.id == n}.first
        @neighbors.each{|k| k.recieve_status (@rp.id)}
        @subtract = [check_battery, @rp.check_battery].min
      end
    when :choose
      @subtract = 0
      @rp = nil
    when :listen, :wait
      return true
    end
  end

  def recieve_status id
    case @now
    when :listen
      add_invite(id)
      return true
    when :wait
      if id == @id
        @subtract = [check_battery, @rp.check_battery].min
      end
      return true
    else
      return false
    end
  end
end

module Match_Red_Acts
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
      update_weight
      @next = :exchange
    when :exchange
      update_edges
      @next = :choose
    when :choose
      choose_role
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end
end

module Match_Deciders
  def choose_edge
    @edges.select{|k| k.criteria == nil}.sample
  end

  def criteria_fulfilled
    !@edges.collect{|k| k.criteria}.include?(nil)
  end

  def choose_round_partner
    case @now
    when :invite
      e = choose_edge
      begin
        i = (e.uv - Set[@id]).first
        @rp = @neighbors.select{|k| k.id == i}.first
      end unless e == nil
    when :respond
      if not @invites.empty? then
        n = @invites.keys.sample
        @rp = @neighbors.select{|k| k.id == n}.first
      end
    end
  end

end
