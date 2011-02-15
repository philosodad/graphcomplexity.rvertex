require 'node_match'
require 'actions_boat'

class BoatNode < MatchRootNode
  include OnOffAble
  include Boat_Acts
  include Boat_Deciders

end
