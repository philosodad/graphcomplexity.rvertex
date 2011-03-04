require 'netgen_pcd'
require 'node_eep'
require 'netgen_tgt'

class DeepsRootGraph < PCDRootGraph
  def reset
    @nodes.each do |k|
      k.set_next :boot
      k.set_now :boot
      k.on = nil
      if k.weight < 0
        k.weight = 0
      end
#      if k.weight == 0
#  k.charges = []
#  k.poorest == nil
#  k.on = false
#  k.set_next :done
#    end
    end
  end
end

class DeepsGraph < DeepsRootGraph
  def put_nodes g
    g.nodes.each{|k| @nodes.push(DeepsNode.new(k))}
  end

  def coverable?
    node = {}
    @nodes.each{|k| node[k.id] = k.weight}
    @edges.each do |k|
      s = 0
      k.each{|j| s += node[j]}
      if s == 0 then return false end
    end
  end

  def covered?
    @nodes.each do |k|
      k.edges.each do |j|
        if !(k.charges.include?(j)) and !(j.v.charges.collect{|l| l.uv}.include?(j.uv)) then 
          puts 'no node is in charge of this edge!'
          return false
        elsif (k.charges.include?(j) and j.v.charges.collect{|l| l.uv}.include?(j.uv)) then
          puts 'two nodes are in charge of this edge!'
          return false
        elsif k.charges.include?(j) and k.off? and k.weight > 0 then
          if !j.v.on then
            puts "this node is in charge, off, and v is off!"
            return false
          end
        elsif j.u.on == nil and j.v.on == nil then
          puts 'the ends of this edge are both nil'
          if j.v.now == :done or j.u.now == :done then
            puts 'and yet one is done'
          elsif j.v.now == :analyze or j.u.now == :analyze then
            puts 'and yet one is in analyze mode'
          end
          return false
        elsif k.weight == 0 and !k.charges.length == 0
          puts 'zero weight in charge of edge!'
          return false
        end
      end
    end
    onlist = Set.new(@nodes.collect{|k| k.id if k.on == true})
    @edges.each{|k| return false if (k & onlist).empty?}
    return true
  end
end

class DeepsRedMinGraph < DeepsGraph
  def put_nodes(g)
    g.nodes.each{|k| @nodes.push(DeepsRedMinNode.new(k))}
  end

  def reset
    @nodes.each do |k|
      if k.weight == 0 then
        k.on = false
        k.neighbors.each{|j| j.on = true}
        k.set_now(:decided)
        k.neighbors.each do |j| 
          j.set_next(:decided)
          j.redundant = false
          j.neighbors.each do |l| 
            l.set_next(:decided)
            l.redundant = false
          end
        end
        k.redundant = false
      end
    end
  end

end

class DeepsMaxMaxGraph < DeepsGraph
  def put_nodes(g)
    g.nodes.each{|k| @nodes.push(DeepsMaxMaxNode.new(k))}
  end
end

class DeepsMinMaxGraph < DeepsGraph
  def put_nodes(g)
    g.nodes.each{|k| @nodes.push(DeepsMinMaxNode.new(k))}
  end
end

class DeepsMinMinGraph < DeepsGraph
  def put_nodes(g)
    g.nodes.each{|k| @nodes.push(DeepsMinMinNode.new(k))}
  end
end
