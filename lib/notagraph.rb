require 'node'
require 'planarmath'
require 'set'

class NotaGraph
  include PlanarMath
  attr_reader :edges, :nodes
  def initialize size
    @nodes = []
    @edges = Set[]
    set_nodes size
    set_neighbors
#    set_edges
  end

  def set_nodes size
    (0...size).each do |x| 
      (0...size-1).each do |y| 
        if y%2 == 0 and x < size-1 then
          @nodes.push(Node.new((x*6)+3,(y*4)))
        elsif y%2 == 1 then
          @nodes.push(Node.new((x*6), (y*4)))
        end
      end
    end
  end
  
  def set_neighbors
    distance = 8
    byx = @nodes.sort_by{|x| x.x}
    byy = @nodes.sort_by{|y| y.y}
    @nodes.each do |k|
      puts k.id if k.id%100 == 0
      possibles = []
      xpossibles = []
      ypossibles = []
      xindex = byx.index(k)
      yindex = byy.index(k)
      up = 1
      down = -1
      until byx[xindex+up] == nil or (byx[xindex+up].x - k.x).abs > distance do
        xpossibles.push(byx[xindex+up])
        up +=1
      end
      until xindex+down < 0 or (byx[xindex+down].x - k.x).abs > distance do
        xpossibles.push(byx[xindex+down])
        down -= 1
      end
      up = 1
      down = -1
      until byy[yindex+up] == nil or (byy[yindex+up].y - k.y).abs > distance do
        ypossibles.push(byy[yindex+up])
        up +=1
      end
      until yindex+down < 0 or (byy[yindex+down].x - k.y).abs > distance do
        ypossibles.push(byy[yindex+down])
        down -= 1
      end
 #     puts "length of possibles: #{possibles.length}"
      possibles = ypossibles + xpossibles
  #    puts "length of possibles: #{possibles.length}"
      k.neighbors.concat(possibles.select{|i| planar_distance(k,i) < distance})        
    end    
  end

  def set_neighbors_obsolete
    @nodes.each do |node|
      puts node.id if node.id%100 == 0
      distance = 8
      possibles = @nodes - [node]
      xmin = node.x - distance
      xmax = node.x + distance
      ymin = node.y - distance
      ymax = node.y + distance
      possibles = possibles.select{|k| k.x >= xmin and k.x <= xmax and k.y >= ymin and k.y <= ymax}
      node.neighbors.concat(possibles)
    end
  end
end
