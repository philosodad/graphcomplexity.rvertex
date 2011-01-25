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
    when :listen, :wait
      return true
    when :update
      @neighbors.each{|k| k.recieve_status id,0,@edges.collect{|k| k.color}}
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
      @deadcolors[id] = criteria
    end
  end
end

module Ec_Deciders
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

  def get_criteria 
    (@colors - @deadcolors[@rp.id]).sort![0]
  end

  def update_colors
    @colors = @colors - @edges.collect{|k| k.color}
  end

  def update_edges
    if @rp
      e = @edges.select{|k| k.uv.include?(@rp.id)}.first
      e.color = @invites[@rp.id]
    end
  end
end
