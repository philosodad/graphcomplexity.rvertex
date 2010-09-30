module Redundant
  include Comparable
  attr_accessor :redundant
  def check_finished
    if @neighbors.select{|k| k.now == :decided or k.now == :finish or k.now == :done}.length == @neighbors.length
      if @on
        if @neighbors.select{|k| !k.on}.empty?
          @redundant = true
        end
      end
      @next = :finish
    else
      @next = :decided
    end
  end
  
  def check_redundant
    if @neighbors.select{|k| k.now == :finish or k.now == :done}.length == @neighbors.length
      if @redundant
        if @neighbors.select{|k| k.redundant}.empty?
          @on = false
        else
          a = @neighbors.select{|k| k.redundant} + [self]
          if a.min == self
            @on = false
          end
        end
      end
      @next = :done
    else
      @next = :finish
    end  
  end

  def <=>(other)
    return nil unless other.instance_of? self.class
    if @weight < other.weight
      return -1
    elsif @weight > other.weight
      return 1
    elsif @id < other.id
      return -1
    else
      return 1
    end
  end
    
end

module Very_Redundant
end
