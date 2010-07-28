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
