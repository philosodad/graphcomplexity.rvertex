class LdNode
  include Comparable
  attr_reader :cover, :id, :lifetime, :degree
  attr_accessor :edges, :nodes, :onremain
  @@id = 0
  def initialize(set)
    @onremain = 0
    @lifetime = 0
    @cover = set
    @degree = 0
    @edges = Set[]
    @id = @@id
    @@id += 1
  end

  def set_degree
    @edges.each{|k| @degree += k[:weight]} unless @edges.empty?
  end

  def set_on_lifetime(nodes)
    @onremain = nodes.select{|k| @cover.include?(k.id) and k.on == nil}.length
    @lifetime = nodes.select{|k| @cover.include?(k.id)}.min_by{|j| j.weight}.weight
  end
  
  def set_onremain(nodes)
    @onremain = nodes.select{|k| @cover.include?(k.id) and k.on != true}.length
  end

  def has?(id)
    return @cover.include?(id)
  end

  def <=>(b)
    if degree < b.degree then
      return -1
    elsif degree > b.degree then
      return 1
    elsif lifetime > b.lifetime
      return -1
    elsif lifetime < b.lifetime
      return 1
    elsif onremain < b.onremain
      return -1
    elsif onremain > b.onremain then
      return 1
    elsif @id < b.id then
      return -1
    elsif @id > b.id then
      return +1
    else
      return 0
    end
 
  end

  def zero_out
    @@id = 0
  end
  
end

class SimpleLdNode < LdNode
  def set_degree nodes
    n = nodes.select{|k| @cover.include?(k.id)}
    n = n.select{|k| !k.on}
    n = n.collect{|k| k.weight}
    @degree = n.inject(0){|i, j| i+j}
  end    

  def set_on_lifetime nodes
    @onremain = nodes.select{|k| @cover.include?(k.id) and k.on == nil}.length
    @lifetime = nodes.select{|k| @cover.include?(k.id) and k.on == nil}.min_by{|j| j.weight}.weight
  end

  def <=>(b)
    if 2*degree < b.degree then
      return -1
    elsif 2*b.degree < degree then
      return 1
    elsif lifetime < b.lifetime
      return -1
    elsif lifetime > b.lifetime
      return 1
    elsif @id < b.id then
      return -1
    elsif @id > b.id then
      return +1
    else
      return 0
    end
  end
end

class TotalWeightLdNode < LdNode
  attr_reader :totalweight
  def initialize set
    super
    @totalweight = 0   
  end
  
  def set_on_lifetime nodes
    @onremain = nodes.select{|k| @cover.include?(k.id) and k.on == nil}.length
    @lifetime = nodes.select{|k| @cover.include?(k.id) and k.on == nil}.max_by{|j| j.weight}.weight
  end

  def set_total_weight nodes
    n = nodes.select{|k| @cover.include?(k.id)}
    n = n.select{|k| !k.on}
    n = n.collect{|k| k.weight}
    @totalweight = n.inject(0){|i, j| i+j}
  end
    
  def <=>(b)
    if totalweight < b.totalweight then
      return -1
    elsif
      totalweight > b.totalweight then
      return 1
    elsif degree < b.degree then
      return -1
    elsif b.degree < degree then
      return 1
    elsif lifetime < b.lifetime
      return -1
    elsif lifetime > b.lifetime
      return 1
    elsif @id < b.id then
      return -1
    elsif @id > b.id then
      return +1
    else
      return 0
    end
  end
end

class DegreeWeightLdNode < TotalWeightLdNode
  def <=>(b)
    if degree < b.degree then
      return -1
    elsif degree > b.degree then
      return 1
    elsif totalweight < b.totalweight then
      return -1
    elsif totalweight > b.totalweight then
      return 1
    elsif lifetime < b.lifetime then
      return -1
    elsif lifetime > b.lifetime then
      return 1
    elsif id < b.id then
      return -1
    elsif id > b.id then
      return 1
    else
      return 0
    end
  end
end
