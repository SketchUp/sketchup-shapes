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
# Name        :   Shapes 1.0
# Description :   Classes for creating and editing parametric shapes
# Menu Item   :   Draw->Shapes->Box
#             :   Draw->Shapes->Cylinder
#             :   Draw->Shapes->Cone
#             :   Draw->Shapes->Torus
#             :   Draw->Shapes->Tube
#             :   Draw->Shapes->Prism
#             :   Draw->Shapes->Pyramid
#             :   Draw->Shapes->Dome
# Context Menu:   Edit Box|Cylinder|Cone|Torus|Tube|Prism|Pyramid|Dome
# Usage       :   Select desired shape and fill in the dialog box that opens.
# Date        :   9/14/2004
# Type        :   Dialog Box
#-----------------------------------------------------------------------------

require 'sketchup.rb'
require 'su_shapes/parametric.rb'
require 'su_shapes/mesh_additions.rb'

module Sketchup::Samples::Shapes
PLUGIN = self

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

    w = data["w"].to_l
    d = data["d"].to_l
    h = data["h"].to_l

    pts = [[0,0,0], [w,0,0], [w,d,0], [0,d,0], [0,0,0]]
    base = container.add_face pts
    h = -h if base.normal.dot(Z_AXIS) < 0.0
    base.pushpull h
end

def default_parameters
    defaults = {"w" => 4.feet, "d" => 4.feet, "h" => 4.feet}
    defaults
end

def translate_key(key)
    prompt = key
    case( key )
        when "w"
            prompt = "Width"
        when "h"
            prompt = "Height"
        when "d"
            prompt = "Depth"
    end
    prompt
end

end

#=============================================================================

class Cylinder < Sketchup::Samples::Parametric

def create_entities(data, container)

    r = data["r"].to_l
    h = data["h"].to_l
    n = 24

    circle = container.add_circle ORIGIN, Z_AXIS, r, n
    base = container.add_face circle
    h = -h if base.normal.dot(Z_AXIS) < 0.0
    base.pushpull h

end

def default_parameters
    defaults = {"r" => 2.feet, "h" => 4.feet}
    defaults
end

def translate_key(key)
    prompt = key
    case( key )
        when "r"
            prompt = "Radius"
        when "h"
            prompt = "Height"
    end
    prompt
end

end

#=============================================================================

class Prism < Sketchup::Samples::Parametric

def create_entities(data, container)

    r = data["r"].to_l
    h = data["h"].to_l
    n = data["n"]

    circle = container.add_ngon ORIGIN, Z_AXIS, r, n
    base = container.add_face circle
    h = -h if base.normal.dot(Z_AXIS) < 0.0
    base.pushpull h

end

def default_parameters
    defaults = {"r" => 2.feet, "h" => 4.feet, "n" => 6}
    defaults
end

def translate_key(key)
    prompt = key
    case( key )
        when "r"
            prompt = "Radius"
        when "h"
            prompt = "Height"
        when "n"
            prompt = "Number of Sides"
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

end

#=============================================================================

class Cone < Sketchup::Samples::Parametric

def create_entities(data, container)

    r = data["r"].to_l
    h = data["h"].to_l
    n = 24

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
    defaults = {"r" => 2.feet, "h" => 4.feet}
    defaults
end

def translate_key(key)
    prompt = key
    case( key )
        when "r"
            prompt = "Radius"
        when "h"
            prompt = "Height"
    end
    prompt
end

end

#=============================================================================

class Torus < Sketchup::Samples::Parametric

def create_entities(data, container)

    r1 = data["r1"].to_l # small radius
    r2 = data["r2"].to_l # big radius
    n1 = 24
    n2 = 24

    # Compute the cross-section circle points
    pts = PLUGIN.points_on_circle([r2, 0, 0], [0, -1, 0], r1, n1)

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
    # make sure that the small radius is less than the big radius
    if( data["r1"] >= data["r2"] )
        UI.messagebox "Inner radius must be smaller than outer radius"
        ok = false
    end
    ok
end

def default_parameters
    defaults = {"r1" => 1.feet, "r2" => 4.feet}
    defaults
end

def translate_key(key)
    prompt = key
    case( key )
        when "r1"
            prompt = "Inner Radius"
        when "r2"
            prompt = "Outer Radius"
    end
    prompt
end

end

#=============================================================================

class Tube < Sketchup::Samples::Parametric

def create_entities(data, container)

    ro = data["r"].to_l
    ri = ro - data["t"].to_l
    h = data["h"].to_l
    n = 24

    outer = container.add_circle ORIGIN, Z_AXIS, ro, n
    face = container.add_face outer
    inner = container.add_circle ORIGIN, Z_AXIS, ri, n
    inner[0].faces.each {|f| f.erase! if( f != face)}
    h = -h if face.normal.dot(Z_AXIS) < 0.0
    face.pushpull h

end

def default_parameters
    defaults = {"r" => 2.feet, "t" => 3.inch, "h" => 4.feet}
    defaults
end

def validate_parameters(data)
    ok = true
    # make sure that the thickness is less than the radius
    if( data["t"] >= data["r"] )
        UI.messagebox "Thickness must be smaller than radius"
        ok = false
    end
    ok
end

def translate_key(key)
    prompt = key
    case( key )
        when "r"
            prompt = "Radius"
        when "t"
            prompt = "Wall Thickness"
        when "h"
            prompt = "Height"
    end
    prompt
end

end

#=============================================================================

class Pyramid < Sketchup::Samples::Parametric

def create_entities(data, container)

    b = data["b"].to_l
    h = data["h"].to_l

    # Create the base
    b2 = b / 2.0
    pts = []
    pts[0] = [-b2, -b2, 0]
    pts[1] = [b2, -b2, 0]
    pts[2] = [b2, b2, 0]
    pts[3] = [-b2, b2, 0]
    container.add_face pts

    # Create the sides
    apex = [0,0,h]
    container.add_face pts[0], apex, pts[1]
    container.add_face pts[1], apex, pts[2]
    container.add_face pts[2], apex, pts[3]
    container.add_face pts[3], apex, pts[0]

end

def default_parameters
    defaults = {"b" => 4.feet, "h" => 4.feet}
    defaults
end

def translate_key(key)
    prompt = key
    case( key )
        when "b"
            prompt = "Base"
        when "h"
            prompt = "Height"
    end
    prompt
end

end

#=============================================================================

class Dome < Sketchup::Samples::Parametric

def create_entities(data, container)

    r = data["r"].to_l
    n90 = data["n"].to_i
    smooth = 12  # smooth

    # compute a quater circle
    arcpts = []
    delta = Math::PI/(2*n90)
    for i in 0..n90 do
        angle = delta * i
        cosa = Math.cos(angle)
        sina = Math.sin(angle)
        arcpts.push(Geom::Point3d.new(r*cosa, 0, r*sina))
    end

    # create a mesh and revolve the quater circle
    numpoly = n90*n90*4
    numpts = numpoly + 1
    mesh = Geom::PolygonMesh.new(numpts, numpoly)
    mesh.add_revolved_points(arcpts, [ORIGIN, Z_AXIS], n90*4)

    # create faces from the mesh
    container.add_faces_from_mesh( mesh, smooth )

end

def default_parameters
    defaults = {"r" => 2.feet, "n" => 5}
    defaults
end

def translate_key(key)
    prompt = key
    case( key )
        when "r"
            prompt = "Radius"
        when "n"
            prompt = "Segments(90)"
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

end

#=============================================================================

# Add a menu to create shapes
if (not $shapes_menu_loaded)
    add_separator_to_menu("Draw")
    shapes_menu = UI.menu("Draw").add_submenu("Shapes")

    shapes_menu.add_item("Box") { Box.new }
    shapes_menu.add_item("Cylinder") { Cylinder.new }
    shapes_menu.add_item("Cone") { Cone.new }
    shapes_menu.add_item("Torus") { Torus.new }
    shapes_menu.add_item("Tube") { Tube.new }
    shapes_menu.add_item("Prism") { Prism.new }
    shapes_menu.add_item("Pyramid") { Pyramid.new }
    shapes_menu.add_item("Dome") { Dome.new }

    $shapes_menu_loaded = true
end

end # module Sketchup::Samples::Shapes
