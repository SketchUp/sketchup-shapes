# Copyright 2014 Trimble Navigation Ltd.
#
# License: The MIT License (MIT)


require "sketchup.rb"
require File.join(File.dirname(__FILE__), 'parametric.rb')
require File.join(File.dirname(__FILE__), 'mesh_additions.rb')

# Load each shape file.
Dir[File.join( File.dirname(__FILE__), 'shapes', '*.rb')].each do |file|
  load( file )
end

module CommunityExtensions::Shapes

  PLUGIN = self # Allows self reference later when calling function in module

  #=============================================================================
  # Find which unit and format the model is using and define unit_length
  #   accordingly
  #   When LengthUnit = 0
  #     LengthFormat 0 = Decimal inches
  #     LengthFormat 1 = Architectural (feet and inches)
  #     LengthFormat 2 = Engineering (feet)
  #     LengthFormat 3 = Fractional (inches)
  #   When LengthUnit = 1
  #     LengthFormat 0 = Decimal feet
  #   When LengthUnit = 2
  #     LengthFormat 0 = Decimal mm
  #   When LengthUnit = 3
  #     LengthFormat 0 = Decimal cm
  #   When LengthUnit = 4
  #     LengthFormat 0 = Decimal metres

  def self.unit_length
    # Get model units (imperial or metric) and length format.
    model = Sketchup.active_model
    manager = model.options
    if provider = manager["UnitsOptions"] # Check for nil value
      length_unit = provider["LengthUnit"] # Length unit value
      length_format = provider["LengthFormat"] # Length format value

      case length_unit
      when 0 ## Imperial units
        if length_format == 1 || length_format == 2
          # model is using Architectural (feet and inches)
          # or Engineering units (feet)
          unit_length = 1.feet
        else
          ## model is using (decimal or fractional) inches
          unit_length = 1.inch
        end # if
      when 1
        ## Decimal feet
        unit_length = 1.feet
      when 2
        ## model is using metric units - millimetres
        unit_length = 10.mm
      when 3
        ## model is using metric units - centimetres
        unit_length = 10.cm
      when 4
        ## model is using metric units - metres
        unit_length =  1.m
      end #end case

    else
      UI.messagebox " Can't determine model units - please set in Window/ModelInfo"
    end # if
  end

  #=============================================================================
  # Function for generating points on a circle
  def self.points_on_circle(center, normal, radius, numseg)
    # Get the x and y axes
    axes = Geom::Vector3d.new(normal).axes
    center = Geom::Point3d.new(center)
    xaxis = axes[0]
    yaxis = axes[1]

    xaxis.length = radius
    yaxis.length = radius

    # compute the points
    vertex_angle = 360.degrees / numseg
    points = []

    for i in 0...numseg do
      angle = i * vertex_angle
      cosa = Math.cos(angle)
      sina = Math.sin(angle)
      vec = Geom::Vector3d.linear_combination(cosa, xaxis, sina, yaxis)
      points.push(center + vec)
    end

    # close the circle
    points.push(points[0].clone)

    points
  end

  # Add a menu for creating 3D shapes
  # Checks if this script file has been loaded before in this SU session
  unless file_loaded?(__FILE__) # If not, create menu entries
    add_separator_to_menu("Draw")
    shapes_menu = UI.menu("Draw").add_submenu("3D Shapes")
    shapes_menu.add_item("Box") { Box.new }
    shapes_menu.add_item("Cylinder") { Cylinder.new }
    shapes_menu.add_item("Cone") { Cone.new }
    shapes_menu.add_item("Torus") { Torus.new }
    shapes_menu.add_item("Tube") { Tube.new }
    shapes_menu.add_item("Prism") { Prism.new }
    shapes_menu.add_item("Pyramid") { Pyramid.new }
    shapes_menu.add_item("Dome") { Dome.new }
    shapes_menu.add_item("Sphere") { Sphere.new }
    shapes_menu.add_item("Helix") { Helix.new }
    file_loaded(__FILE__)
  end

end # module CommunityExtensions::Shapes
