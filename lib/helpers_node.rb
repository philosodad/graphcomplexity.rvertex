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
          if most_valued a
            @on = false
          end
        end
      end
      @next = :done
    else
      @next = :finish
    end  
  end
  
  def most_valued a
    return a.max == self
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

module Redundant_Min
  include Redundant
  def most_valued a
    return a.min == self
  end
end

module Very_Redundant
end

module OnOffAble
  attr_accessor :on, :onlist
  def init_onoff
    @on = nil
    @onlist = {}
  end

  def off?
    if @on == false
      return true
    else
      return false
    end
  end

  def set_ons
    @neighbors.each{|k| @onlist[k.id] = k.on}
    @onlist[@id] = @on
    @neighbors.each{|k| @keyedweights[k.id] = k.weight}
    @keyedweights[@id] = @weight
  end
end

module Weighted
  attr_accessor :weight
  def init_weight
    @keyedweights = {}
    @weight = rand($init_weight) + $init_range
  end
end
