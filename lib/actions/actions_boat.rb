module Boat_Acts
  def do_next
    @next = @now
    case @now
    when :choose
      choose_role
    when :invite
      choose_round_partner
      @next = :wait
    when :listen
      @next = :respond
    when :wait
      @next = :update
    when :respond
      choose_round_partner
      @next = :update
    when :update
      update_criteria
      @next = anchor? ? :anchor : :float
    when :anchor
      @next = :sit
    when :float
      @next = :join
    when :sit
      @next = :push
    when :join
      choose_anchor
      @next = :get
    when :push
      set_floats
      @next = :broadcast
    when :get
      @next = :broadcast
    when :broadcast
      update_criteria
      @next = :account
    when :account
      update_edges
      @next = done? ? :done : :choose
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
    when :listen, :wait, :sit, :float, :get
      true
    when :anchor
      @neighbors.each{|k| recieve_status @id, nil, :anchor}
    when :join
      @neighbors.each{|k| recieve_status @id, @rp.id, get_critera}
    when :push
      @neighbors.each{|k| recieve_status, @id, nil, push_criteria}
    when :broadcast
      @neighbors.each{|k| recieve_status, @id, nil, nil }
    when :choose, :update
      @rp = nil
      @invites = {}
    end
  end

  def recieve_status id, rp, data
    case @now
    when :invite, :anchor, :push, :join, :choose, :respond, :update
      true
    when :listen, :wait, :float, :sit
      add_invite id, rp, data
    when :broadcast
      update_edge id
    end
  end
end

module Boat_Deciders
  def add_invite id, rp, data
    case @now
    when :listen, :sit, :wait
      if rp == @id
        @invites[id] = data
      end
    when :float
      if data == :anchor
        @invites[id] = data
      end
    end
  end

  def choose_anchor
  end

  def set_floats
  end
end
