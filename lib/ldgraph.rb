require 'ldnode'
require 'set'

class LdGraph
  attr_reader :ldnodes, :edges
  def initialize(coverset, nodes)
    @ldnodes = []
    @edges = []
    if not coverset.empty?
      coverset = kill_redundant(coverset)
      coverset.each{|k| @ldnodes.push(LdNode.new(k))}
    end
    if not nodes.empty?
#      rec_edge_build(@ldnodes.dup)
      it_edge_build(@ldnodes.dup)
      set_edge_weight(nodes)
      @ldnodes.each{|k| @edges.each{|j| k.edges.add(j) unless k.cover.intersection(j[:nodes]).empty?}}
      @ldnodes.each{|k| k.set_degree}
      @ldnodes.each{|k| k.set_on_lifetime(nodes)}
      #    puts @ldnodes.inspect
      @ldnodes.sort!
    end
  end

  def it_edge_build(ldnodes)
    a = ldnodes
    while a.length > 1
      g = a.slice!(0)
      a.each do |j|
        unless j.cover.intersection(g.cover).empty?
          edge = {:nodes => j.cover.intersection(g.cover), :weight => 0}
          @edges.push(edge)
        end
      end
    end
    return true
  end
      
    
  def rec_edge_build(ldnodes)
    ld = ldnodes.slice!(0)
    if (ldnodes).empty?
      return true
    else
      (ldnodes).each do |k|
        unless k.cover.intersection(ld.cover).empty?
          edge = {:nodes => k.cover.intersection(ld.cover), :weight => 0}
          @edges.push(edge)
        end
      end
      rec_edge_build(ldnodes)
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
