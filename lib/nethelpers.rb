module Neighborly
  def set_neighbors
    kn = {}
    @nodes.each{|k| kn[k.id] = k}
    @edges.each do |s|
      a = s.to_a
      kn[a[0]].neighbors.push(kn[a[1]])
      kn[a[1]].neighbors.push(kn[a[0]])
    end
  end      
end
