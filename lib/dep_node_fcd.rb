class FCD_Graph_Node
  @@id = 0
  attr_reader :weight, :ids, :id, :neighbors
  def initialize n, nodes
    @weight = nodes.select{|k| n.include?(k.id)}.collect{|k| k.weight}.inject(0){|a,b| a+b}
    @neighbors = []
    @ids = n
    @id = @@id
    @@id +=1
  end

  def <=> (b)
    if @weight < b.weight
      return -1
    elsif @weight > b.weight
      return 1
    elsif @id < b.id
      return -1
    else
      return 1
    end
  end
end
