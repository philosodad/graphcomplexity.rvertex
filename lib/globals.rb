class Globals
  def initialize *args
    if args.length == 0
      $init_weight =  400
      $init_range  = 600
      $step_up = 600
    else
      $init_weight = args[0]
      $init_range = args[1]
      $step_up = args[2]
    end
  end
  
end
