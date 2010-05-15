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
    elsif cover.min < b.cover.min then
      return -1
    elsif cover.min > b.cover.min then
      return +1
    else
      return 0
    end
 
  end

  def zero_out
    @@id = 0
  end
  
end
