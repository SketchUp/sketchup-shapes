module CommunityExtensions::Shapes

  class Box < Parametric

    def create_entities(data, container)
      # Set values from input data
      width = data["width"].to_l # width
      depth = data["depth"].to_l # depth
      height = data["height"].to_l # height

      # Remember values for next use
      @@dimension1 = width
      @@dimension2 = depth
      @@dimension3 = height

      # Draw box
      points = [[0,0,0], [width,0,0], [width,depth,0], [0,depth,0], [0,0,0]]
      base = container.add_face points
      height = -height if base.normal.dot(Z_AXIS) < 0.0
      base.pushpull height
    end

    def default_parameters
      # Set starting defaults to one unit_length
      @@unit_length = PLUGIN.unit_length

      # Set other starting defaults if none set
      if !defined? @@dimension1  # then no previous values input
        defaults = { "width" => @@unit_length, "depth" => @@unit_length,
                     "height" => @@unit_length }
      else
        # Reuse last inputs as defaults
        defaults = { "width" => @@dimension1, "depth" => @@dimension2,
                     "height" => @@dimension3 }
      end # if
    end # default_parameters


    def translate_key(key)
      prompt = key
      case key
      when "width"
        prompt = "Width "
      when "height"
        prompt = "Height "
      when "depth"
        prompt = "Depth "
      end
      prompt
    end

  end # Class Box

end
