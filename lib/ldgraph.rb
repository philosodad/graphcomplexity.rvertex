require 'ldnode'
require 'set'

class LdGraph
  attr_reader :ldnodes, :edges
  def initialize(coverset, nodes)
    @ldnodes = []
    @edges = []
    coverset = kill_redundant(coverset)
    coverset.each{|k| @ldnodes.push(LdNode.new(k))}
    rec_edge_build(@ldnodes)
    set_edge_weight(nodes)
    @ldnodes.each{|k| @edges.each{|j| k.edges.add(j) unless k.cover.intersection(j[:nodes]).empty?}} 
    @ldnodes.each{|k| k.set_degree}
    @ldnodes.each{|k| k.set_on_lifetime(nodes)}
#    puts @ldnodes.inspect
    @ldnodes.sort!
  end

  def rec_edge_build(ldnodes)
    ld = ldnodes.shift
    if ldnodes.empty?
      ldnodes.unshift(ld)
      return true
    else
      ldnodes.each do |k|
        unless k.cover.intersection(ld.cover).empty?
          edge = {:nodes => k.cover.intersection(ld.cover), :weight => 0}
          @edges.push(edge)
        end
      end
      rec_edge_build(ldnodes)
      ldnodes.unshift(ld)
    end
    return true
  end      

  def kill_redundant coverset
    coverset.each do |a|
      coverset.each do |b|
        coverset.delete(b) if a.proper_subset?(b) unless a == b
      end
    end
    return coverset
  end

  def set_edge_weight(nodes)
    @edges.each do |k|
      k[:weight] = nodes.select{|j| k[:nodes].include?(j.id)}.min_by{|i| i.weight}.weight
    end
  end
    
end
