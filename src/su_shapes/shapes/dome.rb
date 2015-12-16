module CommunityExtensions::Shapes

  class Dome < Parametric

    def create_entities(data, container)
      # Set sizes to draw
      radius = data["radius"].to_l  # Base radius
      n90 = data["num_segments"].to_i  # Number of segments per 90 degrees
      smooth = 12  # smooth

      # Remember values for next use
      @@dimension1 = radius
      @@segments = n90

      # Compute a quarter circle
      arcpts = []
      delta = 90.degrees/n90
      for i in 0..n90 do
        angle = delta * i
        cosa = Math.cos(angle)
        sina = Math.sin(angle)
        arcpts.push(Geom::Point3d.new(radius*cosa, 0, radius*sina))
      end

      # Create a mesh and revolve the quarter circle
      numpoly = n90*n90*4
      numpts = numpoly + 1
      mesh = Geom::PolygonMesh.new(numpts, numpoly)
      mesh.extend(PolygonMeshHelper)
      mesh.add_revolved_points(arcpts, [ORIGIN, Z_AXIS], n90*4)

      # Create faces from the mesh
      container.add_faces_from_mesh(mesh, smooth)
    end

    def default_parameters
      # Set starting defaults to one unit_length
      #   and number of segments per 90 degrees to 4
      @@unit_length = PLUGIN.unit_length
      @@segments ||= 4 # per 90 degrees if not previously defined

      # Set other starting defaults if none set
      if !defined? @@dimension1  # then no previous values input
        defaults = { "radius" => @@unit_length, "num_segments" => @@segments }
      else
        # Reuse last inputs as defaults
        defaults = { "radius" => @@dimension1, "num_segments" => @@segments }
      end # if

      # Original default values
      #   defaults = { "radius", 2.feet, "num_segments", 5 }

      # Return values
      defaults
    end

    def translate_key(key)
      prompt = key

      case key
      when "radius"
        prompt = "Radius "
      when "num_segments"
        prompt = "Segments (per 90 deg) "
      end

      # Return value
      prompt
    end

    def validate_parameters(data)
      ok = true

      if(data["num_segments"] < 1)
        UI.messagebox "At least 1 segment required"
        ok = false
      end

      # Return value
      ok
    end

  end # Class Dome

end
