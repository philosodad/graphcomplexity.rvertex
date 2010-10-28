module Minimum_Weight
  def set_weight nodes
    return nodes.collect{|k| k.weight}.min
  end
end

module Cumulative_Weight
  def set_weight nodes
    return nodes.collect{|k| k.weight}.inject(0){|a,b| a + b}
  end
end
