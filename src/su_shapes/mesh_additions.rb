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
# Name        :   Mesh Additions 1.0
# Description :   This file defines some additional methods for Geom::PoygonMesh
# Menu Item   :   NONE
# Context Menu:   NONE
# Date        :   9/16/2004
# Type        :   Utils
#-----------------------------------------------------------------------------

# We are adding new methods to the existing class
class Geom::PolygonMesh

# Revolve edges defined by an array of points about an axis
# pts is an Array of points
# axis is an Array with a point and a vector
# numsegments is the number of segments in the rotaion direction
def add_revolved_points(pts, axis, numsegments)

    # Make sure that there are enough points
    numpts = pts.length
    if( numpts < 2 )
        raise ArgumentError, "At least two points required", caller
    end

    #TODO: Determine if the points are all in the same plane as the axis
    planar = true

    # Create a transformation that will revolve the points
    angle = Math::PI * 2
    da = angle / numsegments
    t = Geom::Transformation.rotation(axis[0], axis[1], da)

    # Add the points to the mesh
    index_array = []
    for pt in pts do
        if( pt.on_line?(axis) )
            index_array.push( [self.add_point(pt)] )
        else
            indices = []
            for i in 0...numsegments do
                indices.push( self.add_point(pt) )
                #puts "add #{pt} at #{indices.last}"
                pt.transform!(t)
            end
            index_array.push indices
        end
    end

    # Now create polygons using the point indices
    i1 = index_array[0]
    for i in 1...numpts do
        i2 = index_array[i]
        n1 = i1.length
        n2 = i2.length
        nest if( n1 < numsegments && n2 < numsegments )

        for j in 0...numsegments do
            jp1 = (j + 1) % numsegments
            if( n1 < numsegments )
                self.add_polygon i1[0], i2[jp1], i2[j]
                #puts "add_poly #{i1[0]}, #{i2[jp1]}, #{i2[j]}"
            elsif( n2 < numsegments )
                self.add_polygon i1[j], i1[jp1], i2[0]
                #puts "add_poly #{i1[j]}, #{i1[jp1]}, #{i2[0]}"
            else
                if( planar )
                    self.add_polygon i1[j], i1[jp1], i2[jp1], i2[j]
                else
                    # Try adding two triangles instead
                    self.add_polygon i1[j], i1[jp1], i2[jp1]
                    self.add_polygon i1[j], i2[jp1], i2[j]
                end
                #puts "add_poly #{i1[j]}, #{i1[jp1]}, #{i2[jp1]}, #{i2[j]}"
            end
        end

        i1 = i2
    end

end

# Extrude points along an axis with a rotation
def add_extruded_points(pts, center, dir, angle, numsegments)

    # Make sure that there are enough points
    numpts = pts.length
    if( numpts < 2 )
        raise ArgumentError, "At least two points required", caller
    end

    # compute the transformation
    vec = Geom::Vector3d.new dir
    distance = vec.length
    dz = distance / numsegments
    da = angle / numsegments
    vec.length = dz
    t = Geom::Transformation.translation vec
    r = Geom::Transformation.rotation center, dir, da
    tform = t * r

    # Add the points to the mesh
    index_array = []
    for i in 0...numsegments do
        indices = []
        for pt in pts do
            indices.push( self.add_point(pt) )
            pt.transform!(tform)
        end
        index_array.push indices
    end

    # Now create polygons using the point indices
    i1 = index_array[0]
    for i in 1...numsegments do
        i2 = index_array[i]

        for j in 0...numpts do
            k = (j+1) % numpts
            self.add_polygon -i1[j], i2[k], -i1[k]
            self.add_polygon i1[j], -i2[j], -i2[k]
        end

        i1 = i2
    end

end

end # Geom::PolygonMesh

module CommunityExtensions

def self.revolve_test(num)
    p0 = Geom::Point3d.new 0, 0, -50
    p1 = Geom::Point3d.new 100, 0, 0
    p2 = Geom::Point3d.new 50, 0, 50
    p3 = Geom::Point3d.new 0, 0, 75
    pts = [p1, p2]
    axis = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(-10, -1, 50)]

    npts = pts.length
    numpts = npts * num
    numpoly = (npts-1)*num
    mesh = Geom::PolygonMesh.new numpts, numpoly

    mesh.add_revolved_points pts, axis, num

    Sketchup.active_model.entities.add_faces_from_mesh mesh, 0
end

def self.extrude_test(dist, angle, num)
    model = Sketchup.active_model
    face = model.selection.first
    if( not face.kind_of?(Sketchup::Face) )
        puts "You must select a Face"
        return
    end
    pts = face.outer_loop.vertices.collect {|v| v.position}
    numpts = num * pts.length
    numpoly = (numpts - pts.length) * 2
    mesh = Geom::PolygonMesh.new numpts, numpoly

    vec = Geom::Vector3d.new 0, 0, dist
    mesh.add_extruded_points pts, ORIGIN, vec, angle, num

    model.entities.add_faces_from_mesh mesh, 9

    true
end

end # module CommunityExtensions
