require 'ldnode'
require 'set'

class LdGraph
  attr_reader :ldnodes, :edges
  def initialize(coverset, nodes)
    @ldnodes = []
    @edges = []
    add_nodes coverset
    set_edges_and_degrees nodes
  end

  def set_edges_and_degrees nodes
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

  def add_nodes coverset
    if not coverset.empty?
      coverset = kill_redundant(coverset)
      coverset.each{|k| @ldnodes.push(LdNode.new(k))}
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
    
  def burn_cover node, nodes
    l = @ldnodes.select{|k| !k.cover.include?(node.id)}
    @ldnodes = []
    @ldnodes = l
    @edges = []
    set_edges_and_degrees nodes
  end
end

class TotalWeightLdGraph < LdGraph
  def initialize(coverset, nodes)
    super
    set_total_weight nodes
  end

  def add_nodes coverset
    if not coverset.empty?
      coverset = kill_redundant(coverset)
      coverset.each{|k| @ldnodes.push(TotalWeightLdNode.new(k))}
    end
  end

  
  def set_total_weight nodes
    @ldnodes.each{|k| k.set_total_weight nodes}
  end
end

class DegreeWeightLdGraph < TotalWeightLdGraph
  def add_nodes coverset
    if not coverset.empty?
      coverset = kill_redundant(coverset)
      coverset.each{|k| @ldnodes.push(DegreeWeightLdNode.new(k))}
    end
  end
end

class SimpleLdGraph < LdGraph
  def add_nodes coverset
    if not coverset.empty?
      coverset.each{|k| @ldnodes.push(SimpleLdNode.new(k))}
    end
  end

  def set_edges_and_degrees nodes
    @ldnodes.each{|k| k.set_degree nodes}
    @ldnodes.each{|k| k.set_on_lifetime nodes}
  end
end

class ShortLifeLdGraph < LdGraph
  def add_nodes coverset
    if not coverset.empty?
      coverset = kill_redundant(coverset)
      coverset.each{|k| @ldnodes.push(ShortLifeLdNode.new(k))}
    end
  end
end
