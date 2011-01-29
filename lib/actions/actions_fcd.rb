module FCD_Acts  
  def recieve_status n
    @onlist.add(n) if n.on
    if @on == nil
      if n.on
        ons = @onlist.collect{|k| k.id}
        @covers.nodes.each_index do |k|
          c = @covers.nodes[k].ids
          if (ons - c.to_a).empty? and c.include?(@id) then
            @cur = k
            break
          end
        end
      elsif !n.on
        @next = :analyze
      end
    end
  end
end
