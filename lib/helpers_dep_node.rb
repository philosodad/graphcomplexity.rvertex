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

module Cleanable
  def kill_redundant coverset
    coverset.each do |a|
      coverset.each do |b|
        coverset.delete(b) if a.proper_subset?(b) unless a == b
      end
    end
    return coverset
  end

end
