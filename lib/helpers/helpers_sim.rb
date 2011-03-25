require 'globals'
#require 'benchmark'

module Sim_To_Done
  def sim *args
    args.length == 0 ? m = 500 : m = args[0]
    g = 0
    f = 0
    w = 0
    until all_done or g > m
      @rg.nodes.each{|k| k.do_next}
      @rg.nodes.each{|k| k.send_status}
      g+=1
    end
    if g > m then f = 1 end
    w = get_the_metric
    if f == 1 then g = 0 end
    $stdout.flush
    #puts "S_T_DONE! #{@id} g: #{g}"
    return w, g, f 
  end

  def get_the_metric
    return @rg.get_on_weight
  end

  def all_done
    return @rg.nodes.select{|k| k.now != :done}.empty?
  end

  def all_decided
    return @rg.nodes.select{|k| (k.now != :decided) and (k.now != :finish) and (k.now != :done)}.empty?
  end
end

module Running_Sim
  def long_sim
    puts 'running sim!'
    t = 0
    s = ""
    f = 0
    while @rg.coverable? do
      i = sim
      if i[1] == 0 then
        puts "#{self.class} overrun, covered: #{self.rg.covered?}"
        f+=1
        break
      elsif !@rg.covered? 
        f += 1 if f == 0
        puts "#{self.class} simmed correctly but not covered!"
        break
      end
      s = s + "#{i}, "
      t += @rg.reduce_by_min
      @rg.reset
    end
#    puts "#{@id} t: #{t}"
    s = s + "#{t}"
    if f != 0 then t = 0 end
    return t, s, f
  end
end

module Stepping_Sim
  def long_sim *args
    puts 'stepping sim!'
    args.empty? ? step = $step_up : step = args[0]
    t = 0
    s = ""
    f = 0
    @counter = 0
    while @rg.coverable? do
      i = sim (@rg.nodes.length * @rg.edges.length)
      if i[1] == 0 then
        puts "#{self.class} overrun, covered: #{self.rg.covered?}"
        f+=1
        break
      elsif !@rg.covered? 
        f += 1 if f == 0
        puts "#{self.class} simmed correctly but not covered!"
        break
      end
      @rg.nodes.each{|k| if k.now != :done then puts "#{k.id} not done" end}
      @rg.coverable? ? @counter += 1 : raise
      s = s + "#{i}, "      
      if @counter == step then
        @counter = 0
        @rg.nodes.each{|k| k.weight -= 1 if k.weight > 0 }
      end
      @rg.nodes.each do |k| 
        if k.on == true
          k.weight -= 1 if k.weight > 0
        end
      end
      t += 1
      @rg = @rg.class.new(@rg)
      set
      #@rg.reset_step
    end
#    puts "#{@id} t: #{t}"
    s = s + "#{t}"
    if f > 0 then t = 0 end
    return t, s, f
  end
end
     
