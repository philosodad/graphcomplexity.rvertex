require 'set'

class DeepsEdge
  include Comparable
  attr_reader :uv
  attr_accessor :type, :supply
  def initialize e
    @uv = e
    @type = nil
    @supply
  end
  
  def <=> other
    if @uv == other.uv
      return 0
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
