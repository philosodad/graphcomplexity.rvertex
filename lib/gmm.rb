

module GMM
  
end

module DGMM
  def choose_role
    if rand(2) == 1 then
      @next = :invite
    else
      @next = :listen
    end
    return @next
  end

  def choose_edge
    eligible = @edges.to_a.select{|k| k.weight == nil}
    if eligible.length == 0 then return :empty end
    return eligible[rand(eligible.length)]
  end

  def update_edge
    
  end

end
