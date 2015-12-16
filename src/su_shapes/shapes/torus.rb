module CommunityExtensions::Shapes

  class Torus < Parametric

    def create_entities(data, container)

      # Set sizes to draw
      # small radius of torus (radius of revolved circle)
      small_radius = data["small_radius"].to_l
      # large radius (outer radius to outside of torus)
      outer_radius = data["outer_radius"].to_l
      # segments in small radius (added by JWM)
      n1 = data["s1"].to_int
      # segments in large radius (added by JWM)
      n2 = data["s2"].to_int

      # Remember values for next use
      @@dimension1 = small_radius
      @@dimension2 = outer_radius
      @@segs1 = n1
      @@segs2 = n2

      # Compute the cross-section circle points
      points = PLUGIN.points_on_circle([outer_radius -small_radius, 0, 0],
                                       [0, -1, 0], small_radius, n1)

      # Now create a polygon mesh and revolve these points
      numpts = n1*n2
      numpoly = numpts
      mesh = Geom::PolygonMesh.new(numpts, numpoly)
      mesh.extend(PolygonMeshHelper)
      mesh.add_revolved_points(points, [ORIGIN, Z_AXIS], n2)

      # create faces from the mesh
      container.add_faces_from_mesh(mesh, 12)

    end

    def validate_parameters(data)
      ok = true

      # make sure that the small radius is no more than half the outer radius
      if data["small_radius"] > data["outer_radius"]/2.0
        UI.messagebox "Small radius must be no more than half the outer radius"
        ok = false
      end

      ok
    end

    def default_parameters
      # Set starting defaults to one unit_length
      #   and number of segments in circle to 16
      @@unit_length = PLUGIN.unit_length

      # Set other starting defaults if none set
      @@segs1 ||= 16
      @@segs2 ||= 16

      # Set other starting defaults if none set
      if !defined? @@dimension1  # then no previous values input
        # set defaults: outer radius = one unit_length, small radius one quarter
        defaults = { "small_radius" => (@@unit_length/4.0).to_l,
                     "outer_radius" => @@unit_length, "s1" => @@segs1,"s2" => @@segs2 }
      else
        # Reuse last inputs as defaults
        defaults = { "small_radius" => @@dimension1,
                     "outer_radius" => @@dimension2,
                     "s1" => @@segs1, "s2" => @@segs2 }
      end # if

      # Return values
      defaults
    end

    def translate_key(key)
      prompt = key
      case key
      when "small_radius"
        prompt = "Profile Radius "
      when "outer_radius"
        prompt = "Torus Radius "
      when "s1"
        prompt = "Profile Segments "
      when "s2"
        prompt = "Torus segments "
      end

      # Return value
      prompt
    end

  end # Class Torus

end
