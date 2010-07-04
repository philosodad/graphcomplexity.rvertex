module StarMachine
  def choose_nodetype
    x = @neighbors.select{|k| !k.on}
    if x.empty? then
      return :done
    elsif rand(2) == 1 then 
      return :notroot 
    else 
      return :notleaf
    end
  end

  def choose_star_edge
    actives = @roots.select{|k| beta(k)/weight + @satlevel == 1.0}
    if actives.empty? then
      return false
    else
      return actives[rand(actives.length)]
    end
  end

  def flip
    if rand(2) == 1 then
#      puts "#{@id}: heads"
      @leaves.each do |k|
        if !@on
          b = beta(k)
          k.satlevel += b/k.weight
#          puts "k is #{k.satlevel}"
          @satlevel += b/@weight
          if k.satlevel.round(5) == 1.0 then 
            k.on = true
            k.next = :done
#            puts "set #{k.id}"
          end
          if @satlevel.round(5) == 1.0
            @on = true
            @next = :done
#            puts "set self #{@id}"
          end
        end
      end
    else
#      puts "#{@id}: tails"
      msat = @satlevel
      on = false
      final = nil
      @leaves.each_index do |k| 
        osat = 0.0
        r = @leaves[k]
        osat += r.satlevel
        if !on
          b = beta(r)
          osat += b/r.weight
          msat += b/@weight
          if msat.round(5) == 1.0
            on = true
          end
          final = k
        end
      end 
      if final
        r = @leaves[final]
        b = beta(r)
        r.satlevel += b/r.weight
        @satlevel += b/@weight
        if r.satlevel.round(5) == 1.0 then
          r.on = true
          r.next = :done
 #         puts "set #{r.id}"
        end
        if @satlevel.round(5) == 1.0 then
          @on = true
          @next = :done
 #         puts "set self #{@id}"
        end
      end
    end      
  end

  def beta other
    bet = [(1.0-@satlevel)*@weight, (1.0-other.satlevel)*weight].min
    return bet
  end

end
