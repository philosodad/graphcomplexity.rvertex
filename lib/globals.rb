class Globals
  def initialize *args
    if args.length == 0
      $init_weight =  400
      $init_range  = 600
      $step_up = 1000
      $distance = 1000
      $space = 5000000
    else
      $init_weight = args[0]
      $init_range = args[1]
      $step_up = args[2]
      $distance = args[3]
      $space = args[4]
    end
  end
  
end
