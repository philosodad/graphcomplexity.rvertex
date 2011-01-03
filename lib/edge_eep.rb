require 'set'

class DeepsEdge
  include Comparable
  attr_accessor :type, :supply,  :uv, :u, :v
  def initialize a, b
    @uv = Set[a.id, b.id]
    @u = a
    @v = b
    @type = nil
  end
  
  def supply
    return @u.weight + @v.weight
  end

  def <=> other
    if @supply > other.supply
      return 1
    elsif @supply < other.supply
      return -1
    elsif u.id > other.u.id
      return 1
    elsif u.id < other.u.id
      return -1
    else
      return 1
    end
  end
  
  def == other
    @uv == other.uv
  rescue
    false
  end

  alias eql? ==
    
  def hash
    @uv.hash
  end
end

class DeepsHyperEdge
  include Comparable
  attr_reader :supply, :nodes, :ids
  attr_accessor :type
  def initialize nlist
    @ids = nlist.collect{|k| k.id}.to_set
    @nodes = nlist
    @type = nil
  end

  def supply
    return @nodes.collect{|k| k.weight}.reduce(:+)
  end

  def <=> other
    if supply > other.supply
      return 1
    elsif supply < other.supply
      return -1
    elsif hash > other.hash
      return 1
    elsif hash < hash
      return -1
    end
  end

  def == other
    @ids == other.ids
  rescue
    false
  end
  alias eql? ==

  def hash
    code = 17
    @ids.each{|k| code = 37*code + k.hash}
    code
  end
end
