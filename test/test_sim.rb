$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sim'

class TestSim < Test::Unit::TestCase
  def setup
    @sn10 = SetNode.new(0)
    @sn11 = SetNode.new(1)
    @sn12 = SetNode.new(2)
    @sn13 = SetNode.new(3)
    @sn14 = SetNode.new(4)
    @sn15 = SetNode.new(5)
    @sn10.weight = 100
    @sn11.weight = 45
    @sn12.weight = 45
    @sn13.weight = 50
    @sn14.weight = 100
    snodes2 = [@sn10, @sn11, @sn12, @sn13, @sn14, @sn15]
    edges = Set.new([Set[0,1],Set[0,2],Set[0,3],Set[1,4], Set[1,3], Set[2,3], Set[2,4]])
    g = SetGraph.new(snodes2, edges)
    @sg = SetSimulator.new(g)
    @udg = UDGSimulator.new(80, 1000, 120)
 #   @rg = RandomSimulator.new(50, @udg.rg.edges.length)
    @rg = RandomSimulator.new(17, 70)
    @ig = RandomSimulator.new(50, 150)
    @gg = GridSimulator.new(5,2)
    @wg = TotalWeightSimulator.new(5,2)
    @mg = MatchSimulator.new(@gg.rg)
    @tg = StarSimulator.new(@gg.rg)
    @pg = PCDSimulator.new(@ig.rg)
    @dg = MatchRedSimulator.new(@ig.rg)
    @eg = PCDDeltaSimulator.new(@ig.rg)
    @ng = MatchSimulator.new(@ig.rg)
    @ag = PCDAllSimulator.new(@ig.rg)
    @lg = StarRedSimulator.new(@ig.rg)
    @kg = StarSimulator.new(@ig.rg)
    @bg = RandomRedSimulator.new(@ig.rg)
    @og = PCDAllSimulatorNoRed.new(@ig.rg)
    @ug = DumbRedSimulator.new(@ig.rg)
    @vg = RandomShortRedSimulator.new(@ig.rg)
    @rg.set
    @sg.set
    @mg.set
    @pg.set
    @dg.set
    @eg.set
#    @rg.rg.nodes.each{|k| puts k.covers.inspect}
    puts "initialized"
  end
  def test_giant
    puts 'testing giant'
    @giant = PCDAllSimulator.new(RandomGraph.new(100,1000))
    @giant.set
    assert @giant.sim < 500
  end

  def test_pg
    puts "testing pg"
    [@pg, @eg, @og, @ug, @dg, @eg, @ng, @bg,@lg,@ag].each do |k|
      assert_equal k.get_total_weight, @ig.get_total_weight
    end
    [@ng, @ag, @og, @ug, @vg].each{|k| k.set}
    [@bg, @ig, @vg].each do |k|
      k.set
      k.set_covers
    end
    assert @pg.rg.coverable?
    assert @pg.sim < 500, "pg > 500"
    assert @eg.sim < 500, "eg > 500"
    assert @dg.sim < 500, "dg > 500"
    assert @ng.sim < 500, "ng > 500"
    assert @ag.sim < 500, "ag > 500"
    assert @bg.sim < 500, "bg > 500"
    assert @ig.sim < 500, "ig > 500"
    assert @og.sim < 500, "og > 500"
    assert @vg.sim < 500, 'vg > 500'
    assert @ug.sim < 500, "ug > 500"
    assert @ag.rg.covered?, "ag not covered"
    assert @eg.rg.covered?, "eg not covered"
    assert @ug.rg.covered?, "ug not covered"
    assert @og.rg.covered?, "og not covered"
    if @lg.sim < 20000 then
      f = @lg.get_on_weight
    else
      f = @lg.get_total_weight
    end
    if @kg.sim < 20000 then
      g = @kg.get_on_weight
    else
      g = @kg.get_total_weight
    end
    i = @ig.get_on_weight
    j = @bg.get_on_weight
    b = @pg.get_on_weight
    a = @dg.get_on_weight
    c = @eg.get_on_weight
    d = @ng.get_on_weight
    e = @ag.get_on_weight
    h = @ig.get_total_weight
    k = @og.get_on_weight
    l = @ug.get_on_weight
    v = @vg.get_on_weight
    puts "\n#{@ng.id} Match Two:\t#{d}\t#{@dg.id} Match Red:\t#{a}\n#{@pg.id} PCD Norm:\t#{b}\t#{@ag.id}\t#{@og.id} PCD All \t #{k}\t#{@ag.id} PCD Red\t#{e}\t#{@eg.id} PCD Delta\t#{c}\n#{@kg.id} Star Norm\t#{g}\t#{@lg.id} Star Red\t#{f}\nLDG Norm #{@ig.id}\t#{i}\t#{@bg.id} LDG Red\t#{j}\n#{@vg.id}: LDG Short \t #{v}\n#{@ug.id} Dumb Red\t#{l}\n Total\t#{h}"
  end

  def test_ug
    puts "testing dumb"
    @ug.set
    @ug.rg.nodes.each do |k| 
      assert !k.neighbors.empty?, "ug node has no neighbors"
      assert !k.edges.empty?, "ug node has no edges"
    end
    assert !@ug.rg.edges.empty?, "ug edges are empty"
  end

  def test_tg
    puts "testing starsim"
    @tg.set
#    @tg.set_covers
    assert @tg.sim < 500, "tg > 500"
  end

  def test_mg
    puts "testing matchsim"
    assert_equal @mg.rg.covered?, false
    assert @mg.sim < 500
    assert_equal @mg.rg.covered?, true
    @gg.set
    @gg.set_covers
    assert_equal @gg.rg.covered?, false
    @gg.sim
    assert_equal @gg.rg.covered?, true
    b = @gg.get_on_weight
    puts "\nb: #{b}"
    puts "\ngg: #{@gg.get_on_weight}, mg:#{@mg.get_on_weight}"
    @mg.rg.nodes.each{|k| k.on = true}
    puts "\mgmod: #{@mg.get_on_weight}"
  end

  def test_gg
    puts "testing gridsim"
    a = @gg.get_on_weight
    puts "a: #{a}"
    @gg.set
    @gg.set_covers
    assert @gg.sim < 500, "grid simulator > 500"
    b = @gg.get_on_weight
    puts "b: #{b}"
    assert_not_equal a,b
    @gg.rg.nodes.each{|k| k.on = true}
    assert_equal @gg.rg.covered?, true
  end

  def test_udg
#    @udg.set
#    @udg.set_covers
#    assert @udg.sim < 500
  end

  def test_randomsim
    @rg.set_covers
    assert @rg.sim < 500
#    @rg.rg.nodes.each{|k| puts k.covers.inspect}
  end

  def test_longsim
    puts "testing long sim"
    @ag.set
    a,b,c = @ag.long_sim
    assert_equal c, 0
#    @pg.long_sim
  end

  def test_setsim
    @sg.set
    @sg.set_covers
#    assert @sg.sim < 500
#    [@sn11,@sn12,@sn13].each{|k| assert_equal k.on, true}
#    [@sn10, @sn14].each{|k| assert_equal k.on, false}
  end

  def teardown
    @mg.rg.nodes.each{|k| k.edges.each{|j| j = nil}}
    [@wg,@ng, @rg, @sg, @gg, @udg, @mg, @tg, @sg, @eg, @ag, @pg].each do |k| 
      k.rg.nodes[0].zero_out
      k.rg.nodes.each{|k| k = nil}
      k.zero_out
    end
    [@wg, @ng, @rg, @sg, @gg, @udg, @mg, @tg, @sg, @eg, @ag, @pg].each{|k| k = nil}

  end
end
