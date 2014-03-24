# Copyright 2014 Trimble Navigation Ltd.
#
# License: The MIT License (MIT)


require "sketchup.rb"
require File.join(File.dirname(__FILE__), 'parametric.rb')
require File.join(File.dirname(__FILE__), 'mesh_additions.rb')

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

#=============================================================================

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

#=============================================================================

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

#=============================================================================

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
#=============================================================================

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

#=============================================================================
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
  mesh.add_revolved_points(pts, [ORIGIN, Z_AXIS], n2)

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

#=============================================================================

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
    defaults = { "radius" => @@unit_length,
      "thickness" => (@@unit_length/10.0).to_l,
      "height" => @@unit_length,"num_segments" => @@segments }
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

#=============================================================================

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

#=============================================================================

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

#======================================================
class Sphere < Parametric

def create_entities(data, container)
  # Set sizes to draw
  radius = data["radius"].to_l  # Radius
  n90 = data["num_segments"].to_i  # Segments per 90 degrees
  smooth = 12  # smooth parameter

  # Remember values for next use
  @@dimension1 = radius
  @@segments = n90

  # Compute a half circle
  arcpts = []
  delta = 90.degrees/n90
  for i in -n90..n90 do
    angle = delta * i
    cosa = Math.cos(angle)
    sina = Math.sin(angle)
    arcpts.push(Geom::Point3d.new(radius*cosa, 0, radius*sina))
  end

  # Create a mesh and revolve the half circle
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

  # Original defaults
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
    prompt = "Segments(per 90 degrees) "
  end

  # Return value
  prompt
end

def validate_parameters(data)
  ok = true

  if data["num_segments"] < 1
    UI.messagebox "At least 1 segment required"
    ok = false
  end

  # Return value
  ok
end

end # Class Sphere

class Helix < Sketchup::Samples::Parametric

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
#=============================================================================

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
