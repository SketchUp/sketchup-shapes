module CommunityExtensions::Shapes

  class Tube < Parametric

    def create_entities(data, container)
      # Set sizes to draw
      outer_radius = data["radius"].to_l # Outer radius
      thickness = data["thickness"].to_l  # Wall thickness
      inner_radius = outer_radius - thickness      # Inner radius
      height = data["height"].to_l  # Height
      # Number of segments to use for circle (was originally at 24)
      num_segments = data["num_segments"].to_int

      # Remember values for next use
      @@dimension1 = outer_radius
      @@dimension2 = thickness
      @@dimension3 = height
      @@segments = num_segments

      # Draw outer loop of tube.
      outer_edges = container.add_circle(ORIGIN, Z_AXIS, outer_radius, num_segments)
      # Adds a face to the circle, to form the bottom of the tube.
      profile_face = container.add_face(outer_edges)
      # Draw the inner loop of the tuby profile and remove the inner face.
      inner_edges = container.add_circle(ORIGIN, Z_AXIS, inner_radius, num_segments)
      inner_face = inner_edges.first.faces.find { |face| face != profile_face }
      inner_face.erase!
      # Ensure the face is extruded upwards.
      profile_face.reverse! if profile_face.normal.samedirection?(Z_AXIS.reverse)
      # Extrude the profile into a tube.
      profile_face.pushpull(height)

    end

    def default_parameters
      # Set starting defaults to one unit_length
      #  and number of segments in circle to 16
      @@unit_length = PLUGIN.unit_length
      @@segments ||= 16 # Set to 16 if not defined

      # Set other starting defaults if none set
      if !defined? @@dimension3  # then no previous values input
        defaults = {
          "radius"       => @@unit_length,
          "thickness"    => (@@unit_length/10.0).to_l,
          "height"       => @@unit_length,
          "num_segments" => @@segments
        }
      else
        # Reuse last inputs as defaults
        defaults = { "radius" => @@dimension1, "thickness" => @@dimension2,
                     "height" => @@dimension3,
                     "num_segments" => @@segments }
      end # if

      # Original parameters
      # defaults = { "radius", 2.feet, "thickness", 3.inch, "height",
      #   4.feet,"num_segments",16 }

      # Return values
      defaults
    end

    def validate_parameters(data)
      ok = true

      # make sure that the thickness is less than the radius
      if data["thickness"] >= data["radius"]
        UI.messagebox "Wall thickness must be smaller than radius"
        ok = false
      end

      # Return value
      ok
    end

    def translate_key(key)
      prompt = key
      case key
      when "radius"
        prompt = "Radius "
      when "thickness"
        prompt = "Wall Thickness "
      when "height"
        prompt = "Height "
      when "num_segments"
        prompt = "Number of segments " ## added as parameter
      end

      # Return value
      prompt
    end

  end #Class Tube

end
