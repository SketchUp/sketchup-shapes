# The MIT License (MIT)

# Copyright (c) 2014 Trimble Navigation Ltd.

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#-----------------------------------------------------------------------------
# Name        :   Shapes 1.4.1
# Description :   Classes for creating and editing parametric shapes
# Menu Item   :   Draw->Shapes->Box
#             :   Draw->Shapes->Cylinder
#             :   Draw->Shapes->Cone
#             :   Draw->Shapes->Torus
#             :   Draw->Shapes->Tube
#             :   Draw->Shapes->Prism
#             :   Draw->Shapes->Pyramid
#             :   Draw->Shapes->Dome
#             :   Draw->Shapes->Sphere
# Context Menu:   Edit Box|Cylinder|Cone|Torus|Tube|Prism|Pyramid|Dome|Sphere
# Usage       :   Select desired shape and fill in the dialog box that opens.
# Date        :   2014-02-04
# Type        :   Dialog Box
#-----------------------------------------------------------------------------
# Modified to v1.1 J W McClenahan 2013-09-14
# Added parameter for number of segments to draw for Cylinder, Cone, Torus and  Tube, replacing fixed n=24.
# Changed Box default height 
#-----------------------------------------------------------------------------
# Modified to v1.2 J W McClenahan 2013-09-15
# Added code to detect model length units, and set different default sizes for imperial and metric units 
#   in round numbers in each unit system - e.g, substituting 300mm for 1 foot
# Tricky bit was finding where to set module-wide values accessible within each class - copied example 
# of points_in_a_circle function to define a function which returns length_unit as a value (now unit_length)
#-----------------------------------------------------------------------------
#  Modified to v1.3 J W McClenahan 2013-09-20
#   Make initial default sizes one unit in each dimension in model units and format, 
#     or simple x10 multiple of one unit (for mm and cm units)
#   Now remembers last size chosen for shape and presents it as default next time
#		Extended Pyramid to n-gon base, not just square base (requires 3 sides or more in base polygon)
#		Added Class to construct Sphere as well as Dome.
#-----------------------------------------------------------------------------
#		Modified to v1.4 J W McClenahan 2013-09-22
#			Redefined torus big radius so it becomes the overall outer radius defaulting to one unit, 
#			not as at present where it is the radius to the centre of the smaller radius. 
#			Amended torus validation check so that small radius must be no more than half outside radius.
#			Changed small radius default to one quarter outer radius, giving a torus with one half unit central hole
#-----------------------------------------------------------------------------
#		Modified to v1.4.1 J W McClenahan 2013-12-31
#			Adapting to SU2014 Beta - Ruby changed to v2.0 and shapes.rb crashes - won't load
#			All lines like: 
#				defaults = {"r", 2.feet, "h", 4.feet, "n", 6} ## Original values 
#			failed with syntax error 
#			Changed all such lines to the now necessary syntax form, with remembered default values:
#				defaults = {"w" => @@dim1, "d" => @@dim2, "h" => @@dim3} 
#-----------------------------------------------------------------------------

require 'sketchup.rb'
require "su_shapes/parametric.rb"
require "su_shapes/mesh_additions.rb"


module Sketchup::Samples::Shapes
PLUGIN = self # Allows self reference later when calling function in module

#=============================================================================
# Find which unit and format the model is using and define unit_length accordingly
	# When LengthUnit = 0
		# LengthFormat 0 = Decimal inches
		# LengthFormat 1 = Architectural (feet and inches)
		# LengthFormat 2 = Engineering (feet)
		# LengthFormat 3 = Fractional (inches)
	# When LengthUnit = 1
		# LengthFormat 0 = Decimal feet
	# When LengthUnit = 2
		# LengthFormat 0 = Decimal mm
	# When LengthUnit = 3
		# LengthFormat 0 = Decimal cm
	# When LengthUnit = 4
		# LengthFormat 0 = Decimal metres

def self.unit_length
# Get model units (imperial or metric) and length format
  model = Sketchup.active_model
  manager = model.options
  if provider = manager['UnitsOptions'] # Check for nil value
    lu = provider['LengthUnit'] # Length unit value
    lf = provider['LengthFormat'] # Length format value

    case (lu )
    when 0 ## Imperial units
      if lf == 1 or lf == 2  
      ## model is using Architectural (feet and inches) or Engineering units (feet)  
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
    UI.messagebox " Can't determine model units - please set them in Window/ModelInfo"
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
  da = (Math::PI * 2) / numseg
  pts = []

  for i in 0...numseg do
    angle = i * da
    cosa = Math.cos(angle)
    sina = Math.sin(angle)
    vec = Geom::Vector3d.linear_combination(cosa, xaxis, sina, yaxis)
    pts.push(center + vec)
  end

  # close the circle
  pts.push(pts[0].clone)

  pts
end

#=============================================================================

class Box < Sketchup::Samples::Parametric

def create_entities(data, container)
  # Set values from input data
  w = data["w"].to_l # width
  d = data["d"].to_l # depth
  h = data["h"].to_l # height

  # Remember values for next use
  @@dim1 = w
  @@dim2 = d
  @@dim3 = h
    
    pts = [[0,0,0], [w,0,0], [w,d,0], [0,d,0], [0,0,0]]
    base = container.add_face pts
    h = -h if base.normal.dot(Z_AXIS) < 0.0
    base.pushpull h
end

def default_parameters
  ## Set starting defaults to one unit_length
  @@ul = PLUGIN.unit_length
  
  if !defined? @@dim1  # then no previous values input
    defaults = {"w" => @@ul, "d" => @@ul, "h" => @@ul }
  else
    # Reuse last inputs as defaults
    defaults = {"w" => @@dim1, "d" => @@dim2, "h" => @@dim3}
  end # if
end # default_parameters

def translate_key(key)
  prompt = key

  case( key )
  when "w"
    prompt = "Width "
  when "h"
    prompt = "Height "
  when "d"
    prompt = "Depth "
  end

  prompt
end

end # Class Box

#=============================================================================

class Cylinder < Sketchup::Samples::Parametric

def create_entities(data, container)
  r = data["r"].to_l # Radius
  h = data["h"].to_l # Height
  n = data["s"].to_int # Number of segments in circle - was originally fixed at n=24

  # Remember values for next use
  @@dim1 = r
  @@dim2 = h
  @@segs = n
  
  circle = container.add_circle ORIGIN, Z_AXIS, r, n
  base = container.add_face circle
  h = -h if base.normal.dot(Z_AXIS) < 0.0
  base.pushpull h

end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments in circle to 16
  @@ul = PLUGIN.unit_length

  if !defined? @@segs
    @@segs = 16
  end

  if !defined? @@dim1  # then no previous values input
    defaults = {"r" => @@ul, "h" => @@ul, "s" => @@segs }
  else
    # Reuse last inputs as defaults
    defaults = {"r" => @@dim1, "h" => @@dim2, "s" => @@segs}
  end # if

  defaults
end

def translate_key(key)
  prompt = key

  case( key )
  when "r"
    prompt = "Radius "
  when "h"
    prompt = "Height "
  when "s"
    prompt = "Number of segments " ## added as parameter
  end

  prompt
end

end # Class Cylinder

#=============================================================================

class Prism < Sketchup::Samples::Parametric

def create_entities(data, container)

  r = data["r"].to_l  # base radius
  h = data["h"].to_l  # height to apex
  n = data["n"].to_int  # number of sides

  # Remember values for next use
  @@dim1 = r
  @@dim2 = h
  @@segs = n
  
  circle = container.add_ngon ORIGIN, Z_AXIS, r, n
  base = container.add_face circle
  h = -h if base.normal.dot(Z_AXIS) < 0.0
  base.pushpull h
  
end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments in circle to 16
  @@ul = PLUGIN.unit_length

  if !defined? @@segs
    @@segs = 6
  end

  if !defined? @@dim1  # then no previous values input
    defaults = {"r" => @@ul, "h" => @@ul, "n" => @@segs }
  else
    # Reuse last inputs as defaults
    defaults = {"r" => @@dim1, "h" => @@dim2, "n" => @@segs}
  end # if
    defaults
    ## defaults = {"r", 2.feet, "h", 4.feet, "n", 6} ## Original values
end

def translate_key(key)
  prompt = key

  case( key )
  when "r"
    prompt = "Radius "
  when "h"
    prompt = "Height "
  when "n"
    prompt = "Number of Sides "
  end

  prompt
end

def validate_parameters(data)
  ok = true

  # make sure that there are at least 3 sides
  if( data["n"] < 3 )
    UI.messagebox "At least 3 sides required"
    ok = false
  end
  ok
end

end # class Prism
#=============================================================================

class Cone < Sketchup::Samples::Parametric

def create_entities(data, container)

  r = data["r"].to_l # Base radius
  h = data["h"].to_l # Height to apex
  n = data["s"].to_int ## Number of segments in circle - was originally fixed at n=24
  
  # Remember values for next use
  @@dim1 = r
  @@dim2 = h
  @@segs = n
  
  # Create the base
  circle = container.add_circle ORIGIN, Z_AXIS, r, n
  base = container.add_face circle
  base_edges = base.edges 
  
  # Create the sides
  apex = [0,0,h]
  e1 = nil
  e2 = nil
  base_edges.each do |edge|
    e2 = container.add_line edge.start.position, apex
    e2.soft = true
    e2.smooth = true
    if( e1 )
      container.add_face edge, e2, e1
    end
    e1 = e2
  end
  
  # Create the last side face
  edge = base_edges[0]
  container.add_face edge.start.position, edge.end.position, apex
 end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments in circle to 16
  @@ul = PLUGIN.unit_length

  if !defined? @@segs
    @@segs = 16
  end

  if !defined? @@dim1  # then no previous values input
    defaults = {"r" => @@ul, "h" => @@ul, "s" => @@segs }
  else
    # Reuse last inputs as defaults
    defaults = {"r" => @@dim1, "h" => @@dim2, "s" => @@segs}
  end # if

  defaults
end

def translate_key(key)
  prompt = key

  case( key )
  when "r"
    prompt = "Radius "
  when "h"
    prompt = "Height "
  when "s"
    prompt = "Number of segments " ## added as parameter
  end

  prompt
end

end # Class Cone

#=============================================================================
class Torus < Sketchup::Samples::Parametric

def create_entities(data, container)

  r1 = data["r1"].to_l # small radius of torus (radius of revolved circle)
  r2 = data["r2"].to_l # large radius (outer radius to outside of torus)
  n1 = data["s1"].to_int ## segments in small radius (added by JWM)
  n2 = data["s2"].to_int ## segments in large radius (added by JWM)

  # Remember values for next use
  @@dim1 = r1
  @@dim2 = r2
  @@segs1 = n1
  @@segs2 = n2
  
  # Compute the cross-section circle points
  pts = PLUGIN.points_on_circle([r2 -r1, 0, 0], [0, -1, 0], r1, n1)
  
  # Now create a polygon mesh and revolve these points
  numpts = n1*n2
  numpoly = numpts
  mesh = Geom::PolygonMesh.new(numpts, numpoly)
  mesh.add_revolved_points(pts, [ORIGIN, Z_AXIS], n2)

  # create faces from the mesh
  container.add_faces_from_mesh( mesh, 12 )
  
end

def validate_parameters(data)
  ok = true

  # make sure that the small radius is no more than half the outer radius
  if( data["r1"] > data["r2"]/2.0 )
    UI.messagebox "Small radius must be no more than half the outer radius"
    ok = false
  end

  ok
end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments in circle to 16
  @@ul = PLUGIN.unit_length

  if !defined? @@segs1
    @@segs1 = 16
    @@segs2 = 16
  end

  if !defined? @@dim1  # then no previous values input
    # set defaults with outer radius = one unit_length, small radius one quarter of that, 
    defaults = {"r1" => (@@ul/4.0).to_l, "r2" => @@ul, "s1" => @@segs1,"s2" => @@segs2 }
  else
    # Reuse last inputs as defaults
    defaults = {"r1" => @@dim1, "r2" => @@dim2, "s1" => @@segs1, "s2" => @@segs2 }
  end # if

  defaults
end

def translate_key(key)
  prompt = key
  case( key )
  when "r1"
    prompt = "Small Radius "
  when "r2"
    prompt = "Outer Radius "
  when "s1"
    prompt = "Segments - small " ## added as parameter
  when "s2"
    prompt = "Segments - outer " ## added as parameter
  end

  prompt
end

end # Class Torus

#=============================================================================

class Tube < Sketchup::Samples::Parametric

def create_entities(data, container)

  r1 = data["r"].to_l # Outer radius
  t = data["t"].to_l  # Wall thickness
  r2 = r1 - t      # Inner radius
  h = data["h"].to_l  # Height
  n = data["s"].to_int ## was originally fixed n=24

  # Remember values for next use
  @@dim1 = r1
  @@dim2 = t
  @@dim3 = h
  @@segs = n
  
  outer = container.add_circle ORIGIN, Z_AXIS, r1, n
  face = container.add_face outer
  inner = container.add_circle ORIGIN, Z_AXIS, r2, n
  inner[0].faces.each {|f| f.erase! if( f != face)}
  h = -h if face.normal.dot(Z_AXIS) < 0.0
  face.pushpull h
  
end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments in circle to 16
  @@ul = PLUGIN.unit_length
  if !defined? @@segs
    @@segs = 16
  end
  if !defined? @@dim3  # then no previous values input
    defaults = {"r" => @@ul, "t" => (@@ul/10.0).to_l, "h" => @@ul,"s" => @@segs }
  else
    # Reuse last inputs as defaults
    defaults = {"r" => @@dim1, "t" => @@dim2, "h" => @@dim3, "s" => @@segs }
  end # if 
    ## defaults = {"r", 2.feet, "t", 3.inch, "h", 4.feet,"s",16} ## Original parameters
    defaults
end

def validate_parameters(data)
  ok = true

  # make sure that the thickness is less than the radius
  if( data["t"] >= data["r"] )
    UI.messagebox "Wall thickness must be smaller than radius"
    ok = false
  end

  ok
end

def translate_key(key)
  prompt = key
  case( key )
  when "r"
    prompt = "Radius "
  when "t"
    prompt = "Wall Thickness "
  when "h"
    prompt = "Height "
  when "s"
    prompt = "Number of segments " ## added as parameter
  end
  prompt
end

end #Class Tube

#=============================================================================

class Pyramid < Sketchup::Samples::Parametric

def create_entities(data, container)

  r = data["r"].to_l  # Radius
  h = data["h"].to_l  # Height
  n = data["n"].to_int   # Number of sides

  # Remember values for next use
  @@dim1 = r
  @@dim2 = h
  @@segs = n
  
  # draw base and define apex point
  circle = container.add_ngon ORIGIN, Z_AXIS, r, n
  base = container.add_face circle
  apex = [0,0,h]
  base_edges = base.edges 
  
  # Create the sides
  apex = [0,0,h]
  e1 = nil
  e2 = nil
  base_edges.each do |edge|
    e2 = container.add_line edge.start.position, apex
    e2.soft = false
    e2.smooth = false
    if( e1 )
      container.add_face edge, e2, e1
    end
    e1 = e2
  end
  
  # Create the last side face
  edge = base_edges[0]
  container.add_face edge.start.position, edge.end.position, apex   
end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments in circle to 16
  @@ul = PLUGIN.unit_length

  if !defined? @@segs
    @@segs = 4
  end

  if !defined? @@dim1  # then no previous values input
    defaults = {"r" => @@ul, "h" => @@ul, "n" => @@segs }
  else
    # Reuse last inputs as defaults
    defaults = {"r" => @@dim1, "h" => @@dim2, "n" => @@segs }
  end # if
    defaults
    ## defaults = {"r", 2.feet, "h", 4.feet, "n", 6} ## Original values
end

def translate_key(key)
  prompt = key

  case( key )
  when "r"
    prompt = "Radius "
  when "h"
    prompt = "Height "
  when "n"
    prompt = "Number of Sides "
  end

  prompt
end

def validate_parameters(data)
  ok = true

  # make sure that there are at least 3 sides
  if( data["n"] < 3 )
    UI.messagebox "At least 3 sides required"
    ok = false
  end

  ok
end

end # Class Pyramid

#=============================================================================

class Dome < Sketchup::Samples::Parametric

def create_entities(data, container)

  r = data["r"].to_l  # Base radius
  n90 = data["n"].to_i  # Number of segments per 90 degrees
  smooth = 12  # smooth 

  # Remember values for next use
  @@dim1 = r
  @@segs = n90
  
  # compute a quarter circle
  arcpts = []
  delta = Math::PI/(2*n90)
  for i in 0..n90 do
    angle = delta * i
    cosa = Math.cos(angle)
    sina = Math.sin(angle)
    arcpts.push(Geom::Point3d.new(r*cosa, 0, r*sina))
  end

  # create a mesh and revolve the quarter circle
  numpoly = n90*n90*4
  numpts = numpoly + 1
  mesh = Geom::PolygonMesh.new(numpts, numpoly)
  mesh.add_revolved_points(arcpts, [ORIGIN, Z_AXIS], n90*4)

  # create faces from the mesh
  container.add_faces_from_mesh( mesh, smooth )
end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments in circle to 16
  @@ul = PLUGIN.unit_length

  if !defined? @@segs
    @@segs = 5 # per 90 degrees
  end

  if !defined? @@dim1  # then no previous values input
    defaults = {"r" => @@ul, "n" => 5 }
  else
    # Reuse last inputs as defaults
    defaults = {"r" => @@dim1, "n" => @@segs}
  end # if 
  
  ## defaults = {"r", 2.feet, "n", 5} ## original default values

  defaults
end

def translate_key(key)
  prompt = key

  case( key )
  when "r"
    prompt = "Radius "
  when "n"
    prompt = "Segments (per 90 deg) "
  end

  prompt
end

def validate_parameters(data)
  ok = true

  if( data["n"] < 1 )
    UI.messagebox "At least 1 segment required"
    ok = false
  end

  ok
end

end # Class Dome

#======================================================
class Sphere < Sketchup::Samples::Parametric

def create_entities(data, container)

  r = data["r"].to_l  # Radius
  n90 = data["n"].to_i  # Segments per 90 degrees
  smooth = 12  # smooth parameter

  # Remember values for next use
  @@dim1 = r
  @@segs = n90
  
  # compute a half circle
  arcpts = []
  delta = Math::PI/(2*n90)
  for i in -n90..n90 do
    angle = delta * i
    cosa = Math.cos(angle)
    sina = Math.sin(angle)
    arcpts.push(Geom::Point3d.new(r*cosa, 0, r*sina))
  end
  
  # create a mesh and revolve the half circle
  numpoly = n90*n90*4
  numpts = numpoly + 1
  mesh = Geom::PolygonMesh.new(numpts, numpoly)
  mesh.add_revolved_points(arcpts, [ORIGIN, Z_AXIS], n90*4)

  # create faces from the mesh
  container.add_faces_from_mesh( mesh, smooth )
  
end

def default_parameters
  ## Set starting defaults to one unit_length and number of segments per 90 degrees to 5
  @@ul = PLUGIN.unit_length

  if !defined? @@segs
    @@segs = 5 # per 90 degrees
  end

  if !defined? @@dim1  # then no previous values input
    defaults = {"r" => @@ul, "n" => 5 }
  else
    # Reuse last inputs as defaults
    defaults = {"r" => @@dim1, "n" => @@segs}
  end # if 
  ## defaults = {"r", 2.feet, "n", 5} # original defaults

  defaults
end

def translate_key(key)
  prompt = key

  case( key )
  when "r"
    prompt = "Radius "
  when "n"
    prompt = "Segments(per 90 degrees) "
  end

  prompt
end

def validate_parameters(data)
  ok = true

  if( data["n"] < 1 )
    UI.messagebox "At least 1 segment required"
    ok = false
  end

  ok
end

end # Class Sphere
#=============================================================================

# Add a menu to create shapes
if (not $shapes_menu_loaded)
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
  $shapes_menu_loaded = true
end

end # module Sketchup::Samples::Shapes
