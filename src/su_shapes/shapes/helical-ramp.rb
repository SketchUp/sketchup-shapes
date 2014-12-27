module CommunityExtensions::Shapes

  class HelicalRamp < Parametric
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

      # Remember values for next use
      @@dimension1 = start_radius
      @@start_angle = start_angle
      @@dimension2 = end_radius
      @@dimension3 = pitch
      @@dimension4 = ramp_start_width
      @@dimension5 = ramp_end_width
      @@segments = num_segments
      @@rotations = rotations

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

    points1 = []
    x1 = current_radius * Math.cos(start_angle.degrees)
    y1 = current_radius * Math.sin(start_angle.degrees)
    z1 = 0.0
    points1[points1.length] = [x1,y1,z1]

    points2 = []
    x2 = (current_radius + ramp_start_width) * Math.cos(start_angle.degrees)
    y2 = (current_radius + ramp_start_width)* Math.sin(start_angle.degrees)
    z2 = 0.0
    points2[points2.length] = [x2,y2,z2]

    # Create a mesh to hold and display the points
    smooth = 12  # smooth parameter
    numpts = 2 * total_segments
    numpoly = numpts + 1
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

      # Calculate next point on outer helix 
      x4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
        Math.cos(segment * angle + start_angle.degrees)
      y4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
        Math.sin(segment * angle + start_angle.degrees)
      z4 = segment * z_increment
      points2[segment] = [x4,y4,z4]

      #Assign temporary names to corner points of next segment

      pt1 = Geom::Point3d.new(points1[segment - 1])
      pt2 = Geom::Point3d.new(points2[segment - 1])
      pt3 = Geom::Point3d.new(points1[segment])
      pt4 = Geom::Point3d.new(points2[segment])

      # Add next segment (two faces) to mesh 
      if right_hand  # right hand rotation
        # Add first face in segment to mesh: add points counterclockwise
        mesh.add_polygon(pt1, pt2, pt3)
        #Add next face in segment to mesh
        mesh.add_polygon(pt2, pt4, pt3)
      else 
        # Add first face in segment to mesh - left-hand rotation; add points clockwise
        mesh.add_polygon(pt2, pt1, pt3)
        #Add next face in segment to mesh
        mesh.add_polygon(pt4, pt2, pt3)
      end    
      # Increment segment counter
      segment += 1
    end

    # Create faces from the mesh
    container.add_faces_from_mesh mesh, smooth

    if rotations < 0.0 # need to reverse faces
      # still to work out how to get a set of faces to .reverse!
    end
  end 

  def default_parameters
    # Set starting defaults to one unit_length and one rotation along axis, start angle at 0.0 degrees from x-axis 

    @@unit_length = PLUGIN.unit_length
    @@segments ||= 16 # per rotation if not previously defined
    @@rotations ||= 1.0 # if not previously defined
    @@start_angle ||= 0.0 # if not previously defined

    # Set other starting defaults if none set
    if !defined? @@dimension1  # then no previous values input
      defaults = { "start_radius" => @@unit_length, "start_angle" => 0.0, "end_radius" => @@unit_length, 
                   "pitch" => @@unit_length, "ramp_start_width" => @@unit_length, "ramp_end_width" => @@unit_length, 
                   "num_segments" => @@segments, "rotations" => @@rotations }
    else
      # Reuse last inputs as defaults
      defaults = { "start_radius" => @@dimension1, "start_angle" => @@start_angle, "end_radius" => @@dimension2, 
                   "pitch" => @@dimension3, "ramp_start_width" => @@dimension4, "ramp_end_width" => @@dimension5, 
                   "num_segments" => @@segments, "rotations" => @@rotations }
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

    # Return value
    ok
  end

end # Class HelicalRamp

end
