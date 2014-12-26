# Copyright 2014 Trimble Navigation Ltd.
#
# License: The MIT License (MIT)
# v2.1 added HelicalRamp class
# v2.2 added HelicalRampWithSides class

require "sketchup.rb"
File.join(File.dirname(__FILE__), 'parametric.rb').inspect
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
  edge0 = base_edges[0]
  container.add_face edge0.start.position, edge0.end.position, apex
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

class Helix < Parametric

def create_entities(data, container)
  # Set sizes to draw
  start_radius = data["start_radius"].to_l  # Starting radius
  end_radius = data["end_radius"].to_l  # Ending radius
  pitch = data["pitch"].to_l  # Pitch
  num_segments = data["num_segments"].to_int   # Number of segments per 360 degree rotation
  rotations = data["rotations"] # No of rotations (not necessarily integer)
  start_angle = data["start_angle"] # Angle to start at (relative to x-axis)
  ramp_start_width = data["ramp_start_width"] # Width of ramp at start
  ramp_end_width = data["ramp_end_width"] # Width of ramp at start

  # Remember values for next use
  @@dimension1 = start_radius
  @@start_angle = start_angle
  @@dimension2 = end_radius
  @@dimension3 = pitch
  @@dimension4 = ramp_start_width
  @@dimension5 = ramp_end_width
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
  @@rotations ||= 1.0 # one rotation, if not previously defined
  @@start_angle ||= 0.0 # if not previously defined

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

class HelicalRamp < Parametric
# Create ramp in helical form

def create_entities(data, container)
  # Set sizes to draw
  start_radius = data["start_radius"].to_l  # Starting radius
  end_radius = data["end_radius"].to_l  # Ending radius
  ramp_start_width = data["ramp_start_width"].to_l # Width between sides of ramp at start
  ramp_end_width = data["ramp_end_width"].to_l # Width between sides of ramp at end
  pitch = data["pitch"].to_l  # Pitch
  num_segments = data["num_segments"].abs.to_int   # Number of segments per 360 degree rotation
  rotations = data["rotations"] # No of rotations (not necessarily integer)
  start_angle = data["start_angle"] # Angle to start at (relative to x-axis)
  
  # Remember values for next use
  @@dimension1 = start_radius
  @@start_angle = start_angle
  @@dimension2 = end_radius
  @@dimension3 = pitch
  @@dimension4 = ramp_start_width
  @@dimension5 = ramp_end_width
  @@segments = num_segments
  @@rotations = rotations

  # In case rotations is negative (left hand spiral) take absolute value for total_segments  
  total_segments = (num_segments * rotations).abs
  if (rotations > 0.0 && pitch >= 0.0) || (rotations < 0.0 && pitch <= 0.0) # Right hand helix 
    angle    = 2 * Math::PI / num_segments
    right_hand = TRUE
  else if 
    (rotations < 0.0 && pitch >= 0.0) || (rotations > 0.0 && pitch <= 0.0) # Left hand helix
    angle    = -2 * Math::PI / num_segments
    right_hand = FALSE
    end
  end
  cosangle = Math.cos(angle)
  sinangle = Math.sin(angle)

  segment = 1
  z_increment = pitch / num_segments

  current_radius = start_radius
  delta_radius = (end_radius - start_radius) / total_segments
  
  delta_width = (ramp_end_width - ramp_start_width) / total_segments

  points1 = []
  x1 = current_radius * Math.cos(start_angle.degrees)
  y1 = current_radius * Math.sin(start_angle.degrees)
  z1 = 0.0
  points1[points1.length] = [x1,y1,z1]
  
  points2 = []
  x2 = (current_radius + ramp_start_width) * Math.cos(start_angle.degrees)
  y2 = (current_radius + ramp_start_width)* Math.sin(start_angle.degrees)
  z2 = 0.0
  points2[points2.length] = [x2,y2,z2]

# Create a mesh to hold and display the points
  smooth = 12  # smooth parameter
  numpts = 2 * total_segments
  numpoly = numpts + 1
  mesh = Geom::PolygonMesh.new(numpts, numpoly)
  # Points at start
  inner_start_point = Geom::Point3d.new(x1,y1,z1)
  outer_start_point = Geom::Point3d.new(x2,y2,z2)
  mesh.add_point(inner_start_point)
  mesh.add_point(outer_start_point)
  
  
  # Draw rest of points
  while segment < total_segments + 1
  # Calculate next point on inner helix
    x3 = (current_radius + (delta_radius * segment)) * Math.cos(segment * angle + start_angle.degrees)
    y3 = (current_radius + (delta_radius * segment)) * Math.sin(segment * angle + start_angle.degrees)
    z3 = segment * z_increment
    points1[segment] = [x3,y3,z3]

  # Calculate next point on outer helix 
    x4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
      Math.cos(segment * angle + start_angle.degrees)
    y4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
      Math.sin(segment * angle + start_angle.degrees)
    z4 = segment * z_increment
    points2[segment] = [x4,y4,z4]

  #Assign temporary names to corner points of next segment

    pt1 = Geom::Point3d.new(points1[segment - 1])
    pt2 = Geom::Point3d.new(points2[segment - 1])
    pt3 = Geom::Point3d.new(points1[segment])
    pt4 = Geom::Point3d.new(points2[segment])
    
   # Add next segment (two faces) to mesh 
    if right_hand  # right hand rotation
      # Add first face in segment to mesh: add points counterclockwise
      mesh.add_polygon(pt1, pt2, pt3)
      #Add next face in segment to mesh
      mesh.add_polygon(pt2, pt4, pt3)
    else 
    # Add first face in segment to mesh - left-hand rotation; add points clockwise
      mesh.add_polygon(pt2, pt1, pt3)
      #Add next face in segment to mesh
      mesh.add_polygon(pt4, pt2, pt3)
    end    
    # Increment segment counter
    segment += 1
  end

  # Create faces from the mesh
  container.add_faces_from_mesh mesh, smooth

  if rotations < 0.0 # need to reverse faces
    # still to work out how to get a set of faces to .reverse!
  end
end 

def default_parameters
  # Set starting defaults to one unit_length and one rotation along axis, start angle at 0.0 degrees from x-axis 

  @@unit_length = PLUGIN.unit_length
  @@segments ||= 16 # per rotation if not previously defined
  @@rotations ||= 1.0 # if not previously defined
  @@start_angle ||= 0.0 # if not previously defined
  
  # Set other starting defaults if none set
  if !defined? @@dimension1  # then no previous values input
    defaults = { "start_radius" => @@unit_length, "start_angle" => 0.0, "end_radius" => @@unit_length, 
    "pitch" => @@unit_length, "ramp_start_width" => @@unit_length, "ramp_end_width" => @@unit_length, 
    "num_segments" => @@segments, "rotations" => @@rotations }
  else
  # Reuse last inputs as defaults
    defaults = { "start_radius" => @@dimension1, "start_angle" => @@start_angle, "end_radius" => @@dimension2, 
    "pitch" => @@dimension3, "ramp_start_width" => @@dimension4, "ramp_end_width" => @@dimension5, 
    "num_segments" => @@segments, "rotations" => @@rotations }
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
  when "ramp_start_width"
    prompt = "Width of ramp side to side at start "
  when "ramp_end_width"
    prompt = "Width of ramp side to side at end "
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

  if data["rotations"].abs < 1.0/@@segments
    UI.messagebox "No. of rotations too small - must allow at least one segment to be drawn"
    ok = false
  end

  if data["num_segments"].abs < 3
    UI.messagebox "At least 3 segments per rotation required"
    ok = false
  end
  
  if data["ramp_start_width"] < 0.0
    UI.messagebox "Ramp start width must be positive"
    ok = false
  end
  if data["ramp_end_width"] < 0.0
    UI.messagebox "Ramp end width must be positive"
    ok = false
  end
  
  # Return value
  ok
end

end # Class HelicalRamp

#=============================================================================
class HelicalRampWithSides < Parametric
# Create ramp in helical form

def create_entities(data, container)
  # Set sizes to draw
  start_radius = data["start_radius"].to_l  # Starting radius
  end_radius = data["end_radius"].to_l  # Ending radius
  ramp_start_width = data["ramp_start_width"].to_l # Width between sides of ramp at start
  ramp_end_width = data["ramp_end_width"].to_l # Width between sides of ramp at end
  pitch = data["pitch"].to_l  # Pitch
  num_segments = data["num_segments"].abs.to_int   # Number of segments per 360 degree rotation
  rotations = data["rotations"] # No of rotations (not necessarily integer)
  start_angle = data["start_angle"] # Angle to start at (relative to x-axis)
  side_slope = data["slope"] # Slope of sides (relative to horizontal) in degrees

#  p "Input side slope = " + side_slope.to_s
  # Remember values for next use
  @@dimension1 = start_radius
  @@start_angle = start_angle
  @@dimension2 = end_radius
  @@dimension3 = pitch
  @@dimension4 = ramp_start_width
  @@dimension5 = ramp_end_width
  @@segments = num_segments
  @@rotations = rotations
  @@side_slope = side_slope
  
#p "@@Side_slope = " + @@side_slope.to_s
  # In case rotations is negative (left hand spiral) take absolute value for total_segments  
  total_segments = (num_segments * rotations).abs
  if (rotations > 0.0 && pitch >= 0.0) || (rotations < 0.0 && pitch <= 0.0) # Right hand helix 
    angle    = 2 * Math::PI / num_segments
    right_hand = TRUE
  else if 
    (rotations < 0.0 && pitch >= 0.0) || (rotations > 0.0 && pitch <= 0.0) # Left hand helix
    angle    = -2 * Math::PI / num_segments
    right_hand = FALSE
    end
  end
  cosangle = Math.cos(angle)
  sinangle = Math.sin(angle)

  segment = 1
  z_increment = pitch / num_segments

  current_radius = start_radius
  delta_radius = (end_radius - start_radius) / total_segments
  
  delta_width = (ramp_end_width - ramp_start_width) / total_segments

  # Start of inner side of ramp
  points1 = []
  x1 = current_radius * Math.cos(start_angle.degrees)
  y1 = current_radius * Math.sin(start_angle.degrees)
  z1 = 0.0
  points1[points1.length] = [x1,y1,z1]

  # Start of outer side of ramp
  points2 = []
  x2 = (current_radius + ramp_start_width) * Math.cos(start_angle.degrees)
  y2 = (current_radius + ramp_start_width)* Math.sin(start_angle.degrees)
  z2 = 0.0
  points2[points2.length] = [x2,y2,z2]

  # Start of inner edge of sloping sides
  inv_tan_slope = 1.0/Math.tan(@@side_slope.degrees)
# p "inv_tan_slope = " + inv_tan_slope.inspect
  points5 = []
  x5 = x1 - z1*inv_tan_slope * Math.cos(start_angle.degrees)
  y5 = y1 - z1*inv_tan_slope * Math.sin(start_angle.degrees)
  points5[points5.length] = [x5,y5,0.0]
  # Start of outer edge of sloping sides  
  points6 = []
  x6 = x2 + z1*inv_tan_slope * Math.cos(start_angle.degrees)
  y6 = y2 + z1*inv_tan_slope * Math.sin(start_angle.degrees)
  points6[points6.length] = [x6,y6,0.0]

  # Create a mesh to hold and display the points
  smooth = 12  # smooth parameter
  numpts = 4 * total_segments
  numpoly = numpts + 3
  mesh = Geom::PolygonMesh.new(numpts, numpoly)
  # Points at start
  inner_start_point = Geom::Point3d.new(x1,y1,z1)
  outer_start_point = Geom::Point3d.new(x2,y2,z2)
  mesh.add_point(inner_start_point)
  mesh.add_point(outer_start_point)
  
  # Draw rest of points
  while segment < total_segments + 1
  # Calculate next point on inner helix
    x3 = (current_radius + (delta_radius * segment)) * Math.cos(segment * angle + start_angle.degrees)
    y3 = (current_radius + (delta_radius * segment)) * Math.sin(segment * angle + start_angle.degrees)
    z3 = segment * z_increment
    points1[segment] = [x3,y3,z3]

  # Calculate next point on inner edge of ramp
  # Take absolute value of z in case this is a downward helix (negative pitch)
    x5 = ((current_radius - z3.abs * inv_tan_slope) + (delta_radius * segment)) * 
      Math.cos(segment * angle + start_angle.degrees)
    y5 = ((current_radius - z3.abs * inv_tan_slope) + (delta_radius * segment)) *
      Math.sin(segment * angle + start_angle.degrees)
    # z5 = 0.0
    points5[segment] = [x5,y5,0.0]
    # container.add_cpoint points5[segment] 
  
    # Calculate next point on outer helix 
    x4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
      Math.cos(segment * angle + start_angle.degrees)
    y4 = (current_radius + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
      Math.sin(segment * angle + start_angle.degrees)
    z4 = segment * z_increment
    points2[segment] = [x4,y4,z4]

  # Calculate next point on outer edge of ramp
  # Take absolute value of z in case this is a downward helix (negative pitch)
  x6 = (current_radius +  z3.abs * inv_tan_slope + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
      Math.cos(segment * angle + start_angle.degrees)
    y6 = (current_radius +  z3.abs * inv_tan_slope + ramp_start_width + (delta_radius * segment) + (delta_width * segment)) * 
      Math.sin(segment * angle + start_angle.degrees)
    points6[segment] = [x6,y6,0.0]
    # container.add_cpoint points6[segment]   
    
  #Assign temporary names to corner points of next segment

    pt1 = Geom::Point3d.new(points1[segment - 1])
    pt2 = Geom::Point3d.new(points2[segment - 1])
    pt3 = Geom::Point3d.new(points1[segment])
    pt4 = Geom::Point3d.new(points2[segment])
    pt5 = Geom::Point3d.new(points5[segment - 1])
    pt6 = Geom::Point3d.new(points6[segment - 1])
    pt7 = Geom::Point3d.new(points5[segment])
    pt8 = Geom::Point3d.new(points6[segment])
  
   # Add next segment faces to mesh 
    if right_hand  # right hand rotation
      # Add first face in ramp segment to mesh: add points counterclockwise
      mesh.add_polygon(pt1, pt2, pt3)
      #Add next face in segment to mesh
      mesh.add_polygon(pt2, pt4, pt3)
      # Add first side face (inner)
      mesh.add_polygon(pt1, pt3, pt5)
      # Add second side face (inner)
      mesh.add_polygon(pt3, pt7, pt5)
      # Add first side face (outer)
      mesh.add_polygon(pt2, pt8, pt4)
      # Add second side face (outer)
      mesh.add_polygon(pt2, pt6, pt8)
    else 
    # Add first face in segment to mesh - left-hand rotation; add points clockwise
      mesh.add_polygon(pt2, pt1, pt3)
      #Add next face in segment to mesh
      mesh.add_polygon(pt4, pt2, pt3)
      # Add first side face (inner)
      mesh.add_polygon(pt1, pt5, pt3)
      # Add second side face (inner)
      mesh.add_polygon(pt3, pt5, pt7)
      # Add first side face (outer)
      mesh.add_polygon(pt2, pt4, pt8)
      # Add second side face (outer)
      mesh.add_polygon(pt2, pt8, pt6)

    end    
    # Increment segment counter
    segment += 1
  end

  # Create faces from the mesh
  container.add_faces_from_mesh mesh, smooth

  end 

def default_parameters
  # Set starting defaults to one unit_length and one rotation along axis, start angle at 0.0 degrees from x-axis 

  @@unit_length = PLUGIN.unit_length
  @@segments ||= 16 # per rotation if not previously defined
  @@rotations ||= 1.0
  @@start_angle ||= 0.0

  
  # Set other starting defaults if none set
  if !defined? @@dimension1  # then no previous values input
    defaults = { "start_radius" => @@unit_length, "start_angle" => 0.0, "end_radius" => @@unit_length, 
    "pitch" => @@unit_length, "ramp_start_width" => @@unit_length, "ramp_end_width" => @@unit_length, 
    "num_segments" => @@segments, "rotations" => @@rotations, 
    "slope" => 45.0 }
  else
  # Reuse last inputs as defaults
    defaults = { "start_radius" => @@dimension1, "start_angle" => @@start_angle, "end_radius" => @@dimension2, 
    "pitch" => @@dimension3, "ramp_start_width" => @@dimension4, "ramp_end_width" => @@dimension5, 
    "num_segments" => @@segments, "rotations" => @@rotations, 
    "slope" => @@side_slope }
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
  when "ramp_start_width"
    prompt = "Width of ramp side to side at start "
  when "ramp_end_width"
    prompt = "Width of ramp side to side at end "
  when "pitch"
    prompt = "Pitch (if negative, helix goes down) "
  when "rotations"
    prompt = "No. of rotations (if negative, makes left hand helix) "
  when "num_segments"
    prompt = "Segments per rotation "
  when "slope"
    prompt = "Slope of sides (degrees from horizontal) "
  end

  # Return value
  prompt
end

def validate_parameters(data)
  ok = true

  if data["rotations"].abs < 1.0/@@segments
    UI.messagebox "No. of rotations too small - must allow at least one segment to be drawn"
    ok = false
  end

  if data["num_segments"].abs < 3
    UI.messagebox "At least 3 segments per rotation required"
    ok = false
  end
  
  if data["ramp_start_width"] < 0.0
    UI.messagebox "Ramp start width must be positive"
    ok = false
  end
  if data["ramp_end_width"] < 0.0
    UI.messagebox "Ramp end width must be positive"
    ok = false
  end

#  if data["start_radius"].to_l * Math.tan(data["slope"].degrees) < 
#  data["pitch"].to_l * data["rotations"]
#    UI.messagebox "WARNING: side slope is so shallow that sides will interfere"
#    ok = true
#  end
  
  # Return value
  ok
end

end # Class HelicalRampWithSides

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
  shapes_menu.add_item("Helical Ramp") { HelicalRamp.new }
  shapes_menu.add_item("Helical Ramp with Sides") { HelicalRampWithSides.new }
  file_loaded(__FILE__)
end

end # module CommunityExtensions::Shapes
