require 'node'
require 'star'

class StarNode < BasicNode
  attr_reader :roots, :leaves, :now, :rp
  attr_accessor :next, :satlevel, :on
  include StarMachine
  def initialize(*args)
    if args.size == 1 then
      if args[0].class == Node or SetNode then
        x = args[0].x
        y = args[0].y
        weight = args[0].weight
        id = args[0].id
      else 
        puts "with one argument, you should pass a Node"
      end
    elsif args.size == 2 then
      x = args[0]
      y = args[1]
      weight = nil
    end
    super()
    @id = id unless id == nil
    @x = x
    @y = y
    @weight = weight unless weight == nil
    @next = :choose
    @staredges = Set[]
    @satlevel = 0.0
    @roots = []
    @leaves = []
    @rp = nil
  end

  def do_next
    @now = @next
    case @now
    when :choose
      @next = choose_nodetype
    when :notleaf
      @next = :pause
    when :pause
      @next = :root
    when :root
      @next = :choose
    when :notroot
      @next = :leaf
    when :leaf
      @next = :wait
    when :wait
      @next = :choose
    when :decided
      @next = :done
    end
  end

  def send_status
    case @now
    when :notleaf
      @neighbors.each{|k| k.recieve_status self}
    when :leaf
      @rp = choose_star_edge
      if @rp then @rp.recieve_status(self) end
    when :root
      flip
    when :choose
      @roots = []
      @leaves = []
      @rp = nil
    end
  end

  def recieve_status object
    case @now
    when :notroot
      @roots.push(object)
    when :pause
      @leaves.push(object)
    end
  end
end

class StarRedNode < StarNode
  include Redundant
  def do_next
    @now = @next
    case @now
    when :choose
      @next = choose_nodetype
    when :notleaf
      @next = :pause
    when :pause
      @next = :root
    when :root
      @next = :choose
    when :notroot
      @next = :leaf
    when :leaf
      @next = :wait
    when :wait
      @next = :choose
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end
end
