require 'node'
require 'actions_eep'
require 'edge_eep'

class DeepRootNode < BasicNode
  include DeepsDeciders
  include Comparable
  attr_reader :poorest, :offlist
  attr_accessor :charges
  def initialize(*args)
    if args.size == 1 then
      if args[0].class == LDGNode or SetNode then
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
      id = nil
    end
    super()
    @id = id unless id == nil
    @x = x
    @y = y
    @weight = weight unless weight == nil
    @poorest
    @charges = []
    @offlist = []
    @next = :boot
  end
  
  def set_edges
    @neighbors.each{|k| @edges.add(DeepsEdge.new(self, k))}
  end
  
  def <=> other
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

class DeepsNode < DeepRootNode
  include DeepsActs
end
