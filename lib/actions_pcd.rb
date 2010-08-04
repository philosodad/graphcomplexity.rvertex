module PCD_OneCheck
  def do_next
    @now = @next
    case @now
    when :analyze
      @covers.nodes.sort!
      if @covers.nodes[0].ids.include?(@id)
        @on = true
        @next = :decided
      else 
        @covers.nodes.each do |k|
          if k.weight == 0 and !k.ids.include?(@id)
            @on = false
            @next = :decided
          end
        end
      end
    when :min
      nset = Set.new(@neighbors)
      nnset = Set.new(@neighbors.collect{|k| k.neighbors}.flatten)-nset-Set[self]
      nn = (nset + nnset).to_a
      if @weight < nn.collect{|k| k.weight}.min
        @on = true
        @next = :decided
      else
        @next = :analyze
      end
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end

  def send_status
    x = update_on_off
    if @next == :analyze
      if x
        @next = :min
      end
    end
  end

  def update_on_off
    s = Set[]
    o = Set[]
    c = false
    @neighbors.each do |k| 
      if k.on then s.add(k) end
      k.neighbors.each{|j| if j.on then s.add(j) end}
      if k.off? then o.add(k) end
      k.neighbors.each{|j| if j.off? then o.add(j) end}
    end
    s = s - @onlist - Set[self]
    s.each{|k| @covers.reduce_weight(k)}
    @onlist = @onlist + s
    o = o - @offlist - Set[self]
    o.each{|k| @covers.remove_node(k)}
    @offlist = @offlist + o
    return (o.empty? and s.empty?)
  end
end

module PCD_DeltaCheck
  def do_next
    @now = @next
    case @now
    when :analyze
      @covers.nodes.sort!
      cur = @covers.nodes[0]
      if cur.ids.include?(id)
        offs = cur.ids.select{|k| !@onlist.collect{|j| j.id}.include?(k)}
        if @weight == cur.keyed_weights.select{|k,v| offs.include?(k)}.values.min 
          @on = true
          @next = :decided
        end
      elsif (@neighbors - @onlist.to_a).empty?
        @on = false
        @next = :decided
      end
    when :min
      nset = Set.new(@neighbors)
      nnset = Set.new(@neighbors.collect{|k| k.neighbors}.flatten)-nset-Set[self]
      nn = (nset + nnset).to_a
      if @weight < nn.select{|k| !k.on}.collect{|k| k.weight}.min
        @on = true
        @next = :decided
      else
        @next = :analyze
      end
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end

  def send_status
    x = update_on_off
    if @next == :analyze
      if x
        @next = :min
      end
    end
  end

  def update_on_off
    s = Set[]
    o = Set[]
    c = false
    @neighbors.each do |k| 
      if k.on then s.add(k) end
      k.neighbors.each{|j| if j.on then s.add(j) end}
      if k.off? then o.add(k) end
      k.neighbors.each{|j| if j.off? then o.add(j) end}
    end
    s = s - @onlist - Set[self]
    s.each{|k| @covers.reduce_weight(k)}
    @onlist = @onlist + s
    o = o - @offlist - Set[self]
    o.each{|k| @covers.remove_node(k)}
    @offlist = @offlist + o
    return (o.empty? and s.empty?)
  end
end

module PCD_AllCheck
  def do_next
    @now = @next
    case @now
    when :analyze
      cur = @covers.nodes[@cur]
      if cur.ids.include?(@id)
        @on = true
        @next = :decided
      elsif (@neighbors - @onlist.to_a).empty?
        @on = false
        @next = :decided
      end      
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end

  def send_status
    @neighbors.each{|k| k.recieve_status(self)}
  end

  def recieve_status n
    @onlist.add(n) if n.on
    if @on == nil 
      if n.on
        while !@covers.nodes[@cur].ids.include?(n.id)
          @cur += 1
          @cur = @cur%@covers.nodes.length
        end
      elsif !n.on
        @on = true if weight < n.weight
        @next = :decided
      end
    end
  end
end

module PCDMachine
 def do_next
    @now = @next
    case @now
    when :analyze
      cur = @covers.nodes[@cur]
      if cur.ids.include?(@id)
        @on = true
        @next = :decided
      elsif (@neighbors - @onlist.to_a).empty?
        @on = false
        @next = :decided
      else
        nmin = (@neighbors - @onlist.to_a).collect{|k| k.weight}.min
        if @weight < nmin
          @on = true
          @next = :decided
        else
          @cur = @cur+1
          @next = :analyze
          end
      end      
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end

  def send_status
    if @on or self.off?
      @neighbors.each{|k| k.recieve_status(self)}
    end
  end

  def recieve_status n
    if n.off? and @next == :analyze
      @on = true
      @next = :decided
    else
      @onlist.add(n)
    end
  end
end
