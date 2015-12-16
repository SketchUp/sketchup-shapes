module CommunityExtensions::Shapes

  class Pyramid < Parametric

    def create_entities(data, container)
      # Set sizes to draw
      radius = data["radius"].to_l  # Radius
      height = data["height"].to_l  # Height
      num_segments = data["num_segments"].to_int   # Number of sides

      # Remember values for next use
      @@dimension1 = radius
      @@dimension2 = height
      @@segments = num_segments

      # Draw base and define apex point
      circle = container.add_ngon ORIGIN, Z_AXIS, radius, num_segments
      base = container.add_face circle
      apex = [0,0,height]
      base_edges = base.edges

      # Create the sides
      apex = [0,0,height]
      edge1 = nil
      edge2 = nil
      base_edges.each do |edge|
        edge2 = container.add_line edge.start.position, apex
        edge2.soft = false
        edge2.smooth = false
        if edge1
          container.add_face edge, edge2, edge1
        end
        edge1 = edge2
      end # do

      # Create the last side face
      edge = base_edges[0]
      container.add_face edge.start.position, edge.end.position, apex
    end

    def default_parameters
      # Set starting defaults to one unit_length
      #   and number of sides to 4
      @@unit_length = PLUGIN.unit_length
      @@segments ||= 4 # Set to 4 if not defined

      # Set other starting defaults if not set
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

      # Original values were
      #   defaults = { "radius", 2.feet, "height", 4.feet, "num_segments", 6 }
    end

    def translate_key(key)
      prompt = key

      case key
      when "radius"
        prompt = "Radius "
      when "height"
        prompt = "Height "
      when "num_segments"
        prompt = "Number of Sides "
      end

      # Return value
      prompt
    end

    def validate_parameters(data)
      ok = true

      # make sure that there are at least 3 sides
      if data["num_segments"] < 3
        UI.messagebox "At least 3 sides required"
        ok = false
      end

      # Return value
      ok
    end

  end # Class Pyramid

end
