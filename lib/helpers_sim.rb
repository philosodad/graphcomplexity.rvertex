module Sim_To_Done
  def sim *args
    args.length == 0 ? m = 500 : m = args[0]
    g = 0
    until all_done or g > m
      @rg.nodes.each{|k| k.do_next}
      @rg.nodes.each{|k| k.send_status}
      g+=1
    end
    $stdout.flush
    puts "S_T_DONE! #{@id} g: #{g}"
    return g
  end

  def all_done
    return @rg.nodes.select{|k| k.now != :done}.empty?
  end

  def all_decided
    return @rg.nodes.select{|k| (k.now != :decided) and (k.now != :finish) and (k.now != :done)}.empty?
  end
end

module Stepping_Sim
  def long_sim
    t = 0
    s = ""
    f = 0
    @counter = 0
    while @rg.coverable? do
      i = sim
      @rg.nodes.each{|k| if k.now != :done then puts '#{k.id} not done' end}
      @rg.coverable? ? @counter += 1 : raise
      if i > 500 or !@rg.covered? then f += 1 end
      if @rg.covered? == false then
        puts "#{self.rg.class} simmed but not covered!"
        break
      end
      s = s + "#{i}, "      
      if @counter == 2 then
        @counter = 0
        @rg.nodes.each{|k| k.weight -= 1}
      end
      @rg.nodes.each do |k| 
        if k.on == true
          k.weight -= 1
        end
      end
      t += 1 
      @rg.nodes.each{|k| if k.weight < 0 then k.weight = 0 end}
      @rg = @rg.class.new(@rg)
      set
    end
#    puts "#{@id} t: #{t}"
    s = s + "#{t}"
    return t, s, f
  end
end
     
