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

  def update_neighbor_state id, data
    if data == :done
      @edges.select{|k| k.uv.include?(id)}.first.weight = 0
    end
  end
end

module Colorable
  attr_reader :colors
  attr_writer :deadcolors
  def init_colors x
    @colors = []
    (0...2**x).each{|k| @colors.push k}
    @deadcolors = {}
  end

  def get_dead
    @deadcolors
  end
end

module Directional_Colorable
  attr_reader :legal_in, :legal_out
  def init_colors x
    @colors = []
    (0...2**x).each{|k| @colors.push k}
    @legal_in = @colors
    @legal_out = @colors
  end
end

module Compare_by_Edge
  include Comparable
  def <=> other
    if @edges.reduce(:+) > other.edges.reduce(:+)
      return 1
    elsif @edges.reduce(:+) < other.edges.reduce(:+)
      return -1
    elsif @id > other.id
      return 1
    elsif @id < other.id
      return -1
    else
      return 0
    end
  end
end

module Message_Passer
  attr_writer :next_message
  class Message
    attr_reader :from, :to, :data
    def initialize f,t,d
      @from = f
      @to = t
      @data = d
    end
  end
  
  def test_next_message
    return !@next_message.nil?
  end

  def get_next_message
    p "#{@next_message.from}, #{@next_message.to}, #{@next_message.data}"
  end      
end
    
