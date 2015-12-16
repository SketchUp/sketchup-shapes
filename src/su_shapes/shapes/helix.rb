module CommunityExtensions::Shapes

  class Helix < Parametric

    def create_entities(data, container)
      # Set sizes to draw
      start_radius = data["start_radius"].to_l  # Starting radius
      end_radius = data["end_radius"].to_l  # Ending radius
      pitch = data["pitch"].to_l  # Pitch
      num_segments = data["num_segments"].to_int   # Number of segments per 360 degree rotation
      rotations = data["rotations"] # No of rotations (not necessarily integer)
      start_angle = data["start_angle"] # Angle to start at (relative to x-axis)

      # Remember values for next use
      @@dimension1 = start_radius
      @@start_angle = start_angle
      @@dimension2 = end_radius
      @@dimension3 = pitch
      @@segments = num_segments
      @@rotations = rotations

      # In case rotations is negative (left hand spiral) take absolute value for total_segments
      total_segments = (num_segments * rotations).abs
      if (rotations > 0.0 && pitch > 0.0) || (rotations < 0.0 && pitch < 0.0) # Right hand helix
        angle    = 2 * Math::PI / num_segments
      else
        if (rotations < 0.0 && pitch > 0.0) || (rotations > 0.0 && pitch < 0.0) # Left hand helix
          angle    = -2 * Math::PI / num_segments
        end
      end
      cosangle = Math.cos(angle)
      sinangle = Math.sin(angle)
      cos_start_angle = Math.cos(start_angle.degrees)
      sin_start_angle = Math.sin(start_angle.degrees)

      segment = 1
      z_increment = pitch / num_segments

      current_radius = start_radius
      delta_radius = (end_radius - start_radius) / total_segments

      points = []
      x1 = current_radius * cos_start_angle
      y1 = current_radius * sin_start_angle
      z1 = 0
      points[points.length] = [x1,y1,z1]

      while segment < (total_segments + 1)
        x2 = (current_radius + (delta_radius * segment)) * Math.cos(segment * angle + start_angle.degrees)
        y2 = (current_radius + (delta_radius * segment)) * Math.sin(segment * angle + start_angle.degrees)
        z2 = segment * z_increment
        points[points.length] = [x2,y2,z2]
        segment += 1
      end

      container.add_curve(points)

    end

    def default_parameters
      # Set starting defaults to one unit_length and one rotation along axis, start angle at 0.0 degrees from x-axis

      @@unit_length = PLUGIN.unit_length
      @@segments ||= 16 # per rotation if not previously defined
      @@rotations = 1.0
      @@start_angle = 0.0

      # Set other starting defaults if none set
      if !defined? @@dimension1  # then no previous values input
        defaults = { "start_radius" => @@unit_length, "start_angle" => 0.0, "end_radius" => @@unit_length, "pitch" => @@unit_length,"num_segments" => @@segments, "rotations" => @@rotations }
      else
        # Reuse last inputs as defaults
        defaults = { "start_radius" => @@dimension1, "start_angle" => @@start_angle, "end_radius" => @@dimension2, "pitch" => @@dimension3, "num_segments" => @@segments, "rotations" => @@rotations }
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

      if data["rotations"].abs < 360.degrees/@@segments
        UI.messagebox "No. of rotations too small - must allow at least one segment to be drawn"
        ok = false
      end
      if data["num_segments"] < 2
        UI.messagebox "At least 2 segments per rotation required"
        ok = false
      end

      # Return value
      ok
    end

  end # Class Helix

end
