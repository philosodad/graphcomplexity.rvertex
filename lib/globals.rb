$:.unshift File.join(File.dirname(__FILE__),'..','lib','nodes')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','actions')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','dep_graphs')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','helpers')
$:.unshift File.join(File.dirname(__FILE__),'..','lib','netgens')
class Globals
  def initialize *args
    if args.length == 0
      $init_weight =  400
      $init_range  = 600
      $step_up = 1000
      $distance = 1000
      $space = 5000
      $sensor_range = ($distance/2)
    else
      $init_weight = args[0]
      $init_range = args[1]
      $step_up = args[2]
      $distance = args[3]
      $space = args[4]
      $sensor_range = ($distance/2)
    end
  end
  
end
