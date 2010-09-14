module PCD_One_Acts
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

module PCD_Delta_Acts
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
      if !nn.select{|k| !k.on}.empty? and @weight < nn.select{|k| !k.on}.collect{|k| k.weight}.min then
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

module PCD_All_Acts
    def do_next
    @now = @next
    case @now
    when :analyze
      cur = @covers.nodes[@cur]
      if @covers.nodes.empty? then 
        if @weight > 0
          @on = true
          @next = :decided
        else
          @on = false
          @next = :decided
        end
      elsif (@neighbors - @onlist.to_a).empty?
        @on = false
        @next = :decided
      elsif cur.ids.include?(@id)
        @on = true
        @next = :decided
      else
        @cur += 1
        @cur = @cur%@covers.nodes.length
      end      
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    when :out_of_batt
      @next = :decided
    end
  end

  def send_status
    @neighbors.each{|k| k.recieve_status(self)}
  end
  
  def recieve_status n
    @onlist.add(n) if n.on
    if @on == nil
      if n.on
        if n.weight == @onlist.to_a.collect{|k| k.weight}.min
          @covers.nodes.each_index do |k|
            c = @covers.nodes[k].ids
            if c.include?(@id) and c.include?(n.id) then
              @cur = k
              break
            end
          end
        end
      elsif !n.on
        @next = :analyze
      end
    end
  end
end


module PCD_All_Acts_No_Red
  def do_next
    @now = @next
    case @now
    when :analyze
      cur = @covers.nodes[@cur]
      while cur == nil and !@covers.nodes.empty?
        @covers.nodes.shift
        cur = @covers.nodes[@cur]
      end
      if @covers.nodes.empty? then 
        if @weight > 0
          @on = true
          @next = :done
        else
          @on = false
          @next = :done
        end
      elsif (@neighbors - @onlist.to_a).empty?
        @on = false
        @next = :done
      elsif cur.ids.include?(@id)
        @on = true
        @next = :done
      else
        rem = @neighbors - @onlist.to_a
        ids = [@id] + rem.collect{|k| k.id}
        covs = []
        @covers.nodes.each{|k| covs.push(k)}
        covs.each{|k| if k.ids - ids == k.ids then covs.delete(k) end}
        covs.sort!
        if covs[0].ids.include?(@id)
          @on = true
          @next = :done
        else
          @cur += 1
          @cur = @cur%@covers.nodes.length
        end
      end
    when :done
      @next = :done
    when :out_of_batt
      @next = :done
    end
  end

  def recieve_status n
    @onlist.add(n) if n.on
    if @on == nil
      if n.on
        if n.weight == @onlist.to_a.collect{|k| k.weight}.min
          @covers.nodes.each_index do |k|
            c = @covers.nodes[k].ids
            if c.include?(@id) and c.include?(n.id) then
              @cur = k
              break
            end
          end
        end
      elsif !n.on
        @next = :analyze
      end
    end
  end
end

module PCD_All_Acts_Naive
  def do_next
    @now = @next
    case @now
    when :analyze
      cur = @covers.nodes[@cur]
      while cur == nil and !@covers.nodes.empty?
        @covers.nodes.shift
        cur = @covers.nodes[@cur]
      end
      if @covers.nodes.empty? then 
        if @weight > 0
          @on = true
          @next = :decided
        else
          @on = false
          @next = :decided
        end
      elsif cur.ids.include?(@id)
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
    when :out_of_batt
      @next = :decided
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
        l = @covers.nodes.select{|k| !k.ids.include?(@id)}
        if l.empty? then 
          @on = true
          @next = :decided
        end
      elsif !n.on
        @on = true if (@weight < n.weight or n.off?)
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
