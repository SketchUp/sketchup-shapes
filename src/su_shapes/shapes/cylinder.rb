module CommunityExtensions::Shapes

  class Cylinder < Parametric

    def create_entities(data, container)
      radius = data["radius"].to_l # Radius
      height = data["height"].to_l # Height
      # Number of segments in circle
      num_segments = data["num_segments"].to_int   # was originally fixed at n=24

      # Remember values for next use
      @@dimension1 = radius
      @@dimension2 = height
      @@segments = num_segments

      # Draw cylinder
      circle = container.add_circle ORIGIN, Z_AXIS, radius, num_segments
      base = container.add_face circle
      height = -height if base.normal.dot(Z_AXIS) < 0.0
      base.pushpull height

    end

    def default_parameters
      # Set starting defaults to one unit_length and
      #   number of segments in circle to 16
      @@unit_length = PLUGIN.unit_length
      @@segments ||= 16  # Set to 16 if not previously defined

      # Set other starting defaults if none set
      if !defined? @@dimension1  # then no previous values input
        defaults = { "radius" => @@unit_length, "height" => @@unit_length,
                     "num_segments" => @@segments }
      else
        # Reuse last inputs as defaults
        defaults = { "radius" => @@dimension1, "height" => @@dimension2,
                     "num_segments" => @@segments }
      end # if

      # Return values
      defaults
    end

    def translate_key(key)
      prompt = key

      case key
      when "radius"
        prompt = "Radius "
      when "height"
        prompt = "Height "
      when "num_segments"
        prompt = "Number of segments " ## added as parameter
      end

      # Return value
      prompt
    end

  end # Class Cylinder

end
