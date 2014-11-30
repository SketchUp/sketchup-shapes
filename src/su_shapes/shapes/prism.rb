module CommunityExtensions::Shapes

  class Prism < Parametric

    def create_entities(data, container)

      # Set size to draw
      radius = data["radius"].to_l  # base radius
      height = data["height"].to_l  # height to apex
      num_sides = data["num_sides"].to_int  # number of sides

      # Remember values for next use
      @@dimension1 = radius
      @@dimension2 = height
      @@segments = num_sides

      # Draw prism
      circle = container.add_ngon ORIGIN, Z_AXIS, radius, num_sides
      base = container.add_face circle
      height = -height if base.normal.dot(Z_AXIS) < 0.0
      base.pushpull height

    end

    def default_parameters

      # Set starting defaults to one unit_length,
      #   and number of sides in prism to 6
      @@unit_length = PLUGIN.unit_length
      @@segments ||= 6 # Set to 6 if not previously defined

      # Set other starting defaults if none set
      if !defined? @@dimension1  # then no previous values input
        defaults = { "radius" => @@unit_length, "height" => @@unit_length,
                     "num_sides" => @@segments }
      else
        # Reuse last inputs as defaults
        defaults = { "radius" => @@dimension1, "height" => @@dimension2,
                     "num_sides" => @@segments }
      end # if

      # Return values
      defaults

      # Original values
      #   defaults = { "radius", 2.feet, "height", 4.feet, "num_sides", 6 }
    end

    def translate_key(key)
      prompt = key

      case key
      when "radius"
        prompt = "Radius "
      when "height"
        prompt = "Height "
      when "num_sides"
        prompt = "Number of Sides "
      end

      prompt
    end

    def validate_parameters(data)
      ok = true

      # make sure that there are at least 3 sides
      if data["num_sides"] < 3
        UI.messagebox "At least 3 sides required"
        ok = false
      end
      ok
    end

  end # class Prism

end
