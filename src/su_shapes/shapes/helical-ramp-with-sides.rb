module CommunityExtensions::Shapes
  class HelicalRampWithSides < Parametric
    # Create ramp in helical form

    def create_entities(data, container)
      # Set sizes to draw
      start_radius = data["start_radius"].to_l  # Starting radius
      end_radius = data["end_radius"].to_l  # Ending radius
      ramp_start_width = data["ramp_start_width"].to_l # Width between sides of ramp at start
      ramp_end_width = data["ramp_end_width"].to_l # Width between sides of ramp at end
      pitch = data["pitch"].to_l  # Pitch
      num_segments = data["num_segments"].abs.to_int   # Number of segments per 360 degree rotation
      rotations = data["rotations"] # No of rotations (not necessarily integer)
      start_angle = data["start_angle"] # Angle to start at (relative to x-axis)
      side_slope = data["slope"] # Slope of sides (relative to horizontal) in degrees

      #  p "Input side slope = " + side_slope.to_s
      # Remember values for next use
      @@dimension1 = start_radius
      @@start_angle = start_angle
      @@dimension2 = end_radius
      @@dimension3 = pitch
      @@dimension4 = ramp_start_width
      @@dimension5 = ramp_end_width
      @@segments = num_segments
      @@rotations = rotations
      @@side_slope = side_slope

      #p "@@Side_slope = " + @@side_slope.to_s
      # In case rotations is negative (left hand spiral) take absolute value for total_segments  
      total_segments = (num_segments * rotations).abs
      if (rotations > 0.0 && pitch >= 0.0) || (rotations < 0.0 && pitch <= 0.0) # Right hand helix 
        angle    = 2 * Math::PI / num_segments
        right_hand = TRUE
      else if 
        (rotations < 0.0 && pitch >= 0.0) || (rotations > 0.0 && pitch <= 0.0) # Left hand helix
        angle    = -2 * Math::PI / num_segments
        right_hand = FALSE
      end
    end
    cosangle = Math.cos(angle)
    sinangle = Math.sin(angle)

    segment = 1
    z_increment = pitch / num_segments

    current_radius = start_radius
    delta_radius = (end_radius - start_radius) / total_segments

    delta_width = (ramp_end_width - ramp_start_width) / total_segments

    # Start of inner side of ramp
    points1 = []
    x1 = current_radius * Math.cos(start_angle.degrees)
    y1 = current_radius * Math.sin(start_angle.degrees)
    z1 = 0.0
    points1[points1.length] = [x1,y1,z1]

    # Start of outer side of ramp
    points2 = []
    x2 = (current_radius + ramp_start_width) * Math.cos(start_angle.degrees)
    y2 = (current_radius + ramp_start_width)* Math.sin(start_angle.degrees)
    z2 = 0.0
    points2[points2.length] = [x2,y2,z2]

    # Start of inner edge of sloping sides
    inv_tan_slope = 1.0/Math.tan(@@side_slope.degrees)
    # p "inv_tan_slope = " + inv_tan_slope.inspect
    points5 = []
    x5 = x1 - z1*inv_tan_slope * Math.cos(start_angle.degrees)
    y5 = y1 - z1*inv_tan_slope * Math.sin(start_angle.degrees)
    points5[points5.length] = [x5,y5,0.0]
    # Start of outer edge of sloping sides  
    points6 = []
    x6 = x2 + z1*inv_tan_slope * Math.cos(start_angle.degrees)
    y6 = y2 + z1*inv_tan_slope * Math.sin(start_angle.degrees)
    points6[points6.length] = [x6,y6,0.0]

    # Create a mesh to hold and display the points
    smooth = 12  # smooth parameter
    numpts = 4 * total_segments
    numpoly = numpts + 3
    mesh = Geom::PolygonMesh.new(numpts, numpoly)
    # Points at start
    inner_start_point = Geom::Point3d.new(x1,y1,z1)
    outer_start_point = Geom::Point3d.new(x2,y2,z2)
    mesh.add_point(inner_start_point)
    mesh.add_point(outer_start_point)

    # Draw rest of points
    while segment < total_segments + 1
      # Calculate next point on inner helix
      x3 = (current_radius + (delta_radius * segment)) * Math.cos(segment * angle + start_angle.degrees)
      y3 = (current_radius + (delta_radius * segment)) * Math.sin(segment * angle + start_angle.degrees)
      z3 = segment * z_increment
      points1[segment] = [x3,y3,z3]

      # Calculate next point on inner edge of ramp
      # Take absolute value of z in case this is a downward helix (negative pitch)
      x5 = ((current_radius - z3.abs * inv_tan_slope) + (delta_radius * segment)) * 
        Math.cos(segment * angle + start_angle.degrees)
      y5 = ((current_radius - z3.abs * inv_tan_slope) + (delta_radius * segment)) *
        Math.sin(segment * angle + start_angle.degrees)
      # z5 = 0.0
      points5[segment] = [x5,y5,0.0]
      # container.add_cpoint points5[segment] 

      # Calculate next point on outer helix 
      x4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
        Math.cos(segment * angle + start_angle.degrees)
      y4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
        Math.sin(segment * angle + start_angle.degrees)
      z4 = segment * z_increment
      points2[segment] = [x4,y4,z4]

      # Calculate next point on outer edge of ramp
      # Take absolute value of z in case this is a downward helix (negative pitch)
      x6 = (current_radius +  z3.abs * inv_tan_slope + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
        Math.cos(segment * angle + start_angle.degrees)
      y6 = (current_radius +  z3.abs * inv_tan_slope + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
        Math.sin(segment * angle + start_angle.degrees)
      points6[segment] = [x6,y6,0.0]
      # container.add_cpoint points6[segment]   

      #Assign temporary names to corner points of next segment

      pt1 = Geom::Point3d.new(points1[segment - 1])
      pt2 = Geom::Point3d.new(points2[segment - 1])
      pt3 = Geom::Point3d.new(points1[segment])
      pt4 = Geom::Point3d.new(points2[segment])
      pt5 = Geom::Point3d.new(points5[segment - 1])
      pt6 = Geom::Point3d.new(points6[segment - 1])
      pt7 = Geom::Point3d.new(points5[segment])
      pt8 = Geom::Point3d.new(points6[segment])

      # Add next segment faces to mesh 
      if right_hand  # right hand rotation
        # Add first face in ramp segment to mesh: add points counterclockwise
        mesh.add_polygon(pt1, pt2, pt3)
        #Add next face in segment to mesh
        mesh.add_polygon(pt2, pt4, pt3)
        # Add first side face (inner)
        mesh.add_polygon(pt1, pt3, pt5)
        # Add second side face (inner)
        mesh.add_polygon(pt3, pt7, pt5)
        # Add first side face (outer)
        mesh.add_polygon(pt2, pt8, pt4)
        # Add second side face (outer)
        mesh.add_polygon(pt2, pt6, pt8)
      else 
        # Add first face in segment to mesh - left-hand rotation; add points clockwise
        mesh.add_polygon(pt2, pt1, pt3)
        #Add next face in segment to mesh
        mesh.add_polygon(pt4, pt2, pt3)
        # Add first side face (inner)
        mesh.add_polygon(pt1, pt5, pt3)
        # Add second side face (inner)
        mesh.add_polygon(pt3, pt5, pt7)
        # Add first side face (outer)
        mesh.add_polygon(pt2, pt4, pt8)
        # Add second side face (outer)
        mesh.add_polygon(pt2, pt8, pt6)

      end    
      # Increment segment counter
      segment += 1
    end

    # Create faces from the mesh
    container.add_faces_from_mesh mesh, smooth

  end 

  def default_parameters
    # Set starting defaults to one unit_length and one rotation along axis, start angle at 0.0 degrees from x-axis 

    @@unit_length = PLUGIN.unit_length
    @@segments ||= 16 # per rotation if not previously defined
    @@rotations ||= 1.0
    @@start_angle ||= 0.0


    # Set other starting defaults if none set
    if !defined? @@dimension1  # then no previous values input
      defaults = { "start_radius" => @@unit_length, "start_angle" => 0.0, "end_radius" => @@unit_length, 
                   "pitch" => @@unit_length, "ramp_start_width" => @@unit_length, "ramp_end_width" => @@unit_length, 
                   "num_segments" => @@segments, "rotations" => @@rotations, 
                   "slope" => 45.0 }
    else
      # Reuse last inputs as defaults
      defaults = { "start_radius" => @@dimension1, "start_angle" => @@start_angle, "end_radius" => @@dimension2, 
                   "pitch" => @@dimension3, "ramp_start_width" => @@dimension4, "ramp_end_width" => @@dimension5, 
                   "num_segments" => @@segments, "rotations" => @@rotations, 
                   "slope" => @@side_slope }
    end # if 

    # Return values
    defaults 
  end

  def translate_key(key)
    prompt = key

    case key
    when "start_radius"
      prompt = "Start radius "
    when "start_angle"
      prompt = "Start at (angle in degrees) "
    when "end_radius"
      prompt = "End radius "
    when "ramp_start_width"
      prompt = "Width of ramp side to side at start "
    when "ramp_end_width"
      prompt = "Width of ramp side to side at end "
    when "pitch"
      prompt = "Pitch (if negative, helix goes down) "
    when "rotations"
      prompt = "No. of rotations (if negative, makes left hand helix) "
    when "num_segments"
      prompt = "Segments per rotation "
    when "slope"
      prompt = "Slope of sides (degrees from horizontal) "
    end

    # Return value
    prompt
  end

  def validate_parameters(data)
    ok = true

    if data["rotations"].abs < 1.0/@@segments
      UI.messagebox "No. of rotations too small - must allow at least one segment to be drawn"
      ok = false
    end

    if data["num_segments"].abs < 3
      UI.messagebox "At least 3 segments per rotation required"
      ok = false
    end

    if data["ramp_start_width"] < 0.0
      UI.messagebox "Ramp start width must be positive"
      ok = false
    end
    if data["ramp_end_width"] < 0.0
      UI.messagebox "Ramp end width must be positive"
      ok = false
    end

    #  if data["start_radius"].to_l * Math.tan(data["slope"].degrees) < 
    #  data["pitch"].to_l * data["rotations"]
    #    UI.messagebox "WARNING: side slope is so shallow that sides will interfere"
    #    ok = true
    #  end

    # Return value
    ok
  end

end # Class HelicalRampWithSides

end
