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
# Description :   Classes for creating and editing parametric shapes from the Sketchup Draw/Shapes menu
# Menu Item   :   Draw->Shapes->Box
#             :   Draw->Shapes->Cylinder
#             :   Draw->Shapes->Cone
#             :   Draw->Shapes->Torus
#             :   Draw->Shapes->Tube
#             :   Draw->Shapes->Prism
#             :   Draw->Shapes->Pyramid
#             :   Draw->Shapes->Dome
#             :   Draw->Shapes->Sphere*
# Context Menu:   Edit Box|Cylinder|Cone|Torus|Tube|Prism|Pyramid|Dome|Sphere* [* = added in v1.3]
# Usage       :   Select desired shape and fill in the dialogue box that opens.
# Date        :   Original 2004-09-14. Latest revision 2014-01-29
# Type        :   Dialogue Box
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
#			Changed small radius default to half outer radius, giving a torus with no central hole
#-----------------------------------------------------------------------------
#		Modified to v1.4.1 J W McClenahan 2013-12-31
#			Adapting to SU2014 Beta - Ruby changed to v2.0 and shapes.rb crashes - won't load
#			All lines like: 
#				defaults = {"r", 2.feet, "h", 4.feet, "n", 6} ## Original values,
#			or
#			 defaults = {"w", @@dim1, "d", @@dim2, "h", @@dim3} ## My amended versions
#			failed with syntax error 
#			Changed all such lines to the now necessary syntax form for defining a hash, 
#				with remembered default values:
#				defaults = {"w" => @@dim1, "d" => @@dim2, "h" => @@dim3} 
#			Following open sourcing of the program by Sketchup, renamed module from JWM back to original
#				and renamed files and subfolder from jwm_shapes back to su_shapes
#-----------------------------------------------------------------------------

require 'sketchup.rb'
require 'extensions.rb'

module Sketchup::Samples
module Shapes

# Create the extension.
shapes_ext = SketchupExtension.new 'Shapes Tool', 'su_shapes/shapes.rb'
shapes_ext.description = 'Shapes sample script from SketchUp.com'
shapes_ext.version =  '1.1.2'
shapes_ext.creator = "SketchUp"
shapes_ext.copyright = "2014, Trimble Navigation Limited"

# Register the extension with Sketchup so it show up in the Preferences panel.
Sketchup.register_extension shapes_ext, true

end # module Shapes
end # module Sketchup::Samples
