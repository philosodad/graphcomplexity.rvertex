class LdNode
  attr_reader :cover, :id
  attr_accessor :edges
  @@id = 0
  def initialize(set)
    @cover = set
    @degree = 0
    @edges = Set[]
    @id = @@id
    @@id += 1
  end

  def set_degree
    @edges.each{|k| @degree += k[:weight]}
  end
end
