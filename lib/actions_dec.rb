module Dec_Acts
 def do_next
    @now = @next
    case @now
    when :invite
      choose_round_partner
      @next = :wait
    when :listen
      @next = :respond
    when :respond
      evaluate_invites
      @next = :update_in
    when :wait
      @next = :update_out
    when :update_in, :update_out
      update_edges
      clear_invites
      @next = :exchange
    when :exchange
      update_colors
      clear_invites
      @next = :choose
    when :choose
      reset_variables
      choose_role
    when :done
      @next = :done
    end
  end

 def send_status
   case @now
   when :invite, :respond, :update_in, :update_out, :exchange
     @neighbors.each{|k| k.recieve_status(@next_message)}
   end
 end

 def recieve_status(i)
   case @now
   when :listen, :update_in, :update_out
     @invites.push(i)
   when :wait
     if i.to == @id then
       @invites.push(i)
     end
   when :exchange
     @deadcolors[i.from] = @deadcolors[i.from] | i.data
   end unless !i
 end
end

module Dec_Deciders

  def clear_invites
    @invites = []
  end

  def choose_edge
    @edges.select{|k| k.criteria[:out] == nil}.sample
  end

  def open_edges
    @edges.select{|k| k.criteria[:out] == nil}
  end

  def incoming
    @edges.select{|k| k.criteria[:in] == nil}
  end

  def choose_round_partner
    e = open_edges.sample
    delta = @neighbors.length
    @rp = @neighbors.select{|k| e.uv.include?(k.id)}.first
    @next_message = Message_Passer::Message.new(@id, @rp.id, (@legal_out - @deadcolors[@rp.id])[rand(delta)])
  end

  def reset_variables
    @invites = []
    @next_message = nil
    @rp = nil
  end

  def choose_role
    if @deadcolors == nil or @deadcolors == {}
      @deadcolors = {}
      @neighbors.each{|k| @deadcolors[k.id] = []}
    end

    if criteria_fulfilled? then 
      @next = :done
    elsif open_edges.length == 0
      @next = :listen
    elsif incoming.length == 0
      @next = :invite
    else
      @next = [:invite, :listen].sample
    end
  end

  def evaluate_invites
    my_inv = @invites.select{|k| k.to == @id}
    ot_inv = @invites.reject{|k| k.to == @id}
    free_colors = (my_inv.collect{|k| k.data} - ot_inv.collect{|k| k.data}).uniq 
    inv = my_inv.select{|k| free_colors.include?(k.data)}.sample
    if inv and @legal_in.include?(inv.data)
      @rp = @neighbors.select{|k| k.id == inv.from}.first
      p "edge {#{@id}, #{@rp.id}}"
      @next_message = Message_Passer::Message.new(@id, @rp.id, inv.data)
    else
      p "conflict: #{inv}"
    end
  end

  def update_edges
      if @rp
        e = @edges.select{|k| k.uv.include?(@rp.id)}.first
        case @now
        when :update_in
          e.color[:in] = @next_message.data
        when :update_out
          if @invites.any?
            e.color[:out] = @invites[0].data
          end
        end unless !@next_message
      end
    a = []
    b = []
    @edges.each{|k| a.push(k.color[:in]); b.push(k.color[:out])}
    c = [a.compact, b.compact]
    @next_message = Message_Passer::Message.new(@id,nil,c)
  end

  def update_colors
    d = @legal_out
    f = @legal_out.length
    e = @legal_in
    @colors = @colors - (@edges.collect{|k| k.color.values}.flatten)
    a = []
    b = []
    @invites.each{|k| a.push k.data[0]; b.push k.data[1]}
    @legal_out = (@legal_out - a.flatten) & @colors
    @legal_in = (@legal_in - b.flatten) & @colors
    if a.length > 0 and (a & d).any? and f == @legal_out.length
      raise StandardError, "#{a&d}, #{a&@legal_out}"
    end
    @next_message = Message_Passer::Message.new(@id, nil, b.flatten)
    
  end

  def criteria_fulfilled?
    !@edges.collect{|k| k.criteria}.collect{|k| k.values}.flatten.include?(nil)
  end

end
