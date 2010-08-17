module Sim_To_Done
  def sim *args
    args.length == 0 ? m = 500 : m = args[0]
    g = 0
    until all_done or g > m
      @rg.nodes.each{|k| k.do_next}
      @rg.nodes.each{|k| k.send_status}
      g+=1
    end
    puts "#{@id} g: #{g}"
    return g
  end

  def all_done
    return @rg.nodes.select{|k| k.now != :done}.empty?
  end

  def all_decided
    return @rg.nodes.select{|k| (k.now != :decided) and (k.now != :finish) and (k.now != :done)}.empty?
  end
end
