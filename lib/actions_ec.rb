module EcActs
  def do_next
    @now = @next
    case @now
    when :invite
      choose_round_partner
      @next = :wait
    when :respond
      choose_round_partner
      @next = :update
    when :listen
      @next = :respond
    when :wait
      @next = :update
    when :update
      update_edges
      @next = :exchange
    when :exchange
      update_colors
      @next = :choose
    when :choose
      choose_role
    when :done
      @next = :done
    end
  end

  def send_status
    case @now
    when :invite
      if @rp != nil then @neighbors.each{|k| k.recieve_status @id, @rp.id, get_criteria} end
    when :respond
      if @rp != nil then @neighbors.each{|k| k.recieve_status @id, @rp.id, @invites[@rp.id]} end
    when :choose
      @rp = nil
      @invites = {}
      @deadcolors = []
    when :listen, :wait
      return true
    when :update
      @neighbors.each{|k| k.recieve_status 0,0,@edges.collect{|k| k.color}}
    end
  end

  def recieve_status id, rp, criteria
    case @now
    when :listen
      if rp == @id
        @invites[id] = criteria
      end
    when :wait
      if rp == @id
        if @rp.id == id
          @invites[id] = criteria
        end
      end
    when :update
      @deadcolors.push(criteria)
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
      
      
  def choose_edge
    @edges.select{|k| k.criteria == nil}.sample
  end

  def criteria_fulfilled
    !@edges.collect{|k| k.criteria}.include?(nil)
  end

  def get_criteria 
    return colors[0].to_i
  end

  def update_colors
    @colors = @colors - @deadcolors.flatten
  end

  def update_edges
    if @rp
      e = @edges.select{|k| k.uv.include?(@rp.id)}.first
      e.color = @invites[@rp.id]
    end
  end
end
