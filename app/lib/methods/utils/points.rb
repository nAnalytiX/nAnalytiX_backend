module Methods::Utils::Points
  def self.format_points points
    new_x_points = []
    new_y_points = []

    points['x'].size.times do |i|
      new_x_points << points['x'][i].to_f
      new_y_points << points['y'][i].to_f
    end

    { x: new_x_points, y: new_y_points }
  end

  def self.format_points_v2 points
    new_points = []

    points.size.times do |i|
      p = []

      p[0] = points [i][0].to_f
      p[1] = points [i][1].to_f

      new_points << p
    end

    new_points
  end
  
  def self.validate_points points
    errors = []

    if points[:x].uniq.length != points[:x].length
      errors << 'duplicates_x'
    end

    if points[:y].uniq.length != points[:y].length
      errors << 'duplicates_y'
    end

    errors
  end

  def self.validate_points_v2 points
    errors = []
    points_x = []
    points_y = []

    points.size.times do |i|
      p = []

      points_x << points [i][0]
      points_y << points [i][1]
    end

    if points_x.uniq.length != points_x.length
      errors << 'duplicates_x'
    end

    if points_y.uniq.length != points_y.length
      errors << 'duplicates_y'
    end

    errors
  end

end
