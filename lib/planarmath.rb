module PlanarMath
  def planar_distance(obj1, obj2)
    return ((obj1.x - obj2.x)**2 + (obj1.y - obj2.y)**2)**(0.5)
  end

  def get_side(s,h)
    return ((h**2 - s**2)**0.5).floor
  end

  def coord_within_distance(obj1, distance)
    theta = rand(90)
    r = rand(distance)
    newx = obj1.x.send([:+,:-].sample, (Math.sin(theta).magnitude.*r))
    newy = obj1.y.send([:+,:-].sample, (Math.cos(theta).magnitude.*r))
    return newx, newy
  end
end
