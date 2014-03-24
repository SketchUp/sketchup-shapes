# Copyright 2014 Trimble Navigation Ltd.
#
# License: The MIT License (MIT)


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
