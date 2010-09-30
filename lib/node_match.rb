require 'node'

class MatchNode < BasicNode
  attr_reader :rp, :subtract, :invites
  include DGMM_min
  def initialize(*args)
    if args.size == 1 then
      if args[0].class == LDGNode or SetNode then
        x = args[0].x
        y = args[0].y
        weight = args[0].weight
        id = args[0].id
      else 
        puts "with one argument, you should pass a Node"
      end
    elsif args.size == 2 then
      x = args[0]
      y = args[1]
      weight = nil
      id = nil
    end
    super()
    @id = id unless id == nil
    @x = x
    @y = y
    @weight = weight unless weight == nil
    @next = :choose
    @rp = nil
    @invites = []
    @subtract = 0
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
    e = @edges.to_a
    @edges = Set[]
    e.each{|k| @edges.add(WeightedEdge.new(k))}
  end

  def reset
    @edges.each{|k| k.weight = nil}
    @subtract = 0
    @rp = nil
    @next = :choose
    @now = nil
    @invites = []
    @on = nil
  end

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
        
  def set_now sym
    @now = sym
  end

  def set_rp node
    @rp = node
  end

  def set_next sym
    @next = sym
  end
end

class MatchMaxNode < MatchNode
  include DGMM_max
end

class MatchMWMNode < MatchNode
  include DGMM_mwm
end

class MatchRedNode < MatchNode
  include Redundant
  include DGMM_red
  def initialize *args
    super(*args)
    @redundant = false
  end

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
