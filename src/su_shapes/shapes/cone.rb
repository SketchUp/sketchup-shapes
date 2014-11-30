module CommunityExtensions::Shapes

  class Cone < Parametric

    def create_entities(data, container)
      # Set size to draw
      radius = data["radius"].to_l # Base radius
      height = data["height"].to_l # Height to apex
      # Number of segments in circle (was originally fixed at num_segments=24)
      num_segments = data["num_segments"].to_int

      # Remember values for next use
      @@dimension1 = radius
      @@dimension2 = height
      @@segments = num_segments

      # Create the base
      circle = container.add_circle ORIGIN, Z_AXIS, radius, num_segments
      base = container.add_face circle
      base_edges = base.edges

      # Create the sides
      apex = [0,0,height]
      edge1 = nil
      edge2 = nil
      base_edges.each do |edge|
        edge2 = container.add_line edge.start.position, apex
        edge2.soft = true
        edge2.smooth = true
        if edge1
          container.add_face edge, edge2, edge1
        end
        edge1 = edge2
      end

      # Create the last side face
      edge = base_edges[0]
      container.add_face edge.start.position, edge.end.position, apex
    end

    def default_parameters
      # Set starting defaults to one unit_length
      #   and number of segments in circle to 16
      @@unit_length = PLUGIN.unit_length
      @@segments ||= 16 # Set to 16 if not previously defined

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

  end # Class Cone

end
