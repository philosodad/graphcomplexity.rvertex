#netgen.rb
#Builds networks
require 'node'
require 'planarmath'
require 'set'

class UnitDiskGraph
  include PlanarMath
  attr_reader :edges, :nodes
  def initialize(size, space, distance)
    @nodes = []
    @edges = Set[]
    size.times{@nodes.push(Node.new(rand(space), rand(space)))}
    @nodes.each{|k| setneighbors(k, distance)}
    @nodes.each{|k| k.neighbors.each{|j| @edges.add(Set[k.id, j.id])}}
  end

  def setneighbors(node, distance)
    possibles = @nodes - [node]
    possibles = possibles.select{|k| (k.x - node.x).abs <= distance}
    possibles = possibles.select{|k| (k.y - node.y).abs <= distance}
    node.neighbors.concat(possibles.select{|k| planardist(k, node) <= distance})
  end
end

class SetGraph
  attr_reader :edges, :nodes
  def initialize nodes, edges
    @nodes = nodes
    @edges = edges
    @nodes.each do |k|
      @edges.each do |j|
        if j.include?(k.id)
          k.neighbors.concat(@nodes.select{|i| (j - Set[k.id]).include?(i.id)})
        end
      end
    end
  end
    
end
