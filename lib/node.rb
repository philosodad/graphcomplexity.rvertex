require 'set'
require 'cover'
require 'ldgraph'
require 'automata'
class Node
  include VertexCover
  include BasicAutomata
  attr_reader :x, :y, :id, :edges, :covers, :onlist
  attr_accessor :neighbors, :weight, :on
  @@id = 0
  def initialize(x,y)
    @on = true
    @x = x
    @y = y
    @id
    @neighbors = []
    @edges = Set[]
    updateid
    @covers
    @weight = rand(50)+50
    @currentcover = 0
    @onlist = {}
    set_ons
  end

  def updateid
    @id = @@id
    @@id += 1
  end

  def set_edges
    @neighbors.each{|k| @edges.add(Set[k.id, @id])}
  end

  def set_covers
    @covers = build_covers
  end

  def set_ons
    @neighbors.each{|k| @onlist[k.id] = k.on}
    @neighbors.each{|k| k.neighbors.each{|j| @onlist[j.id] = j.on}}
  end

  def update_covers_on id, status
    if @onlist[id] != status then
      @onlist[id] = status
      @covers.ldnodes.each do |k|
        if k.cover.include?(id) then 
          status ? k.onremain += 1 : k.onremain -=1
        end
      end
    end
  end

  def sort_covers
    @covers.ldnodes.sort!
  end

  def send_status
    @neighbors.each{|k| k.recieve_status(@id, @on)}
  end

  def recieve_status id, status
    case transition id, status
    when true
    when :sendon, :sendoff
      update_covers 
      send_status
    when :reshuffle
    end
  end

  def zero_out
    @@id = 0
  end

end

class SetNode < Node
  def initialize(id)
    super(0,0)
    @id = id
  end

  def updateid
  end
end
