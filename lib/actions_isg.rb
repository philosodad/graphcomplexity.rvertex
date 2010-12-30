module ISG_Acts
  def do_next
    @now = @next
    case @now
    when :analyze
      if no_choice?
        @on = false
        @next = :share
      elsif best_choice?
        @on = true
        @next = :share
      else
        @next = :wait
      end
    when :wait
      @next = :update
    when :update
      update_dep_graph
      @next = :analyze
    when :share
      @next = :done
    when :done
      @next = :done
    end      
  end

  def send_status
    case @next
    when :share
      @neighbors.each{|k| k.recieve_status self}
    when :update, :done
      @neighbors.each{|k| k.recieve_status @onlist, @offlist}
    end
  end

  def recieve_status *args
    if args.size == 1 then
      if args[0].on then
        @onlist.add(args[0].id)
      elsif args[0].off?
        @offlist.add(args[0].id)
      end
    elsif args.size == 2 then
      @onlist = @onlist | args[0]
      @offlist = @offlist | args[1]
    end
  end
end

module ISG_Deciders
  def no_choice?
    return !@neighbors.select{|k| k.on}.empty?
  end
  
  def best_choice?
    if no_choice?
      return false
    else
      return (@covers.current_cover.include? @id) and (@neighbors.select{|k| !k.off?}.max < self)
    end
  end

  def update_dep_graph
    @covers.update_dep_graph @onlist, @offlist
  end
end
