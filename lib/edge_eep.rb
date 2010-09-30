require 'set'

class DeepsEdge
  include Comparable
  attr_accessor :type, :supply,  :uv, :u, :v
  def initialize a, b
    @uv = Set[a.id, b.id]
    @u = a
    @v = b
    @type = nil
    @supply = get_supply
  end
  
  def get_supply
    return @u.weight + @v.weight
  end

  def uv
    return @uv
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
  
  def eql? other
    if @uv == other.uv
      return true
    end
  end

  def hash
    @uv.hash
  end
end
