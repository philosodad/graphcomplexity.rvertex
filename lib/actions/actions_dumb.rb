module Dumb_Acts_Red
  def do_next
    if @neighbors.empty?
      @next = :blah
    end
    @now = @next
    case @now
    when :analyze
      @on = true
      @next = :decided
    when :decided
      check_finished
    when :finish
      check_redundant
    when :done
      @next = :done
    end
  end
end
