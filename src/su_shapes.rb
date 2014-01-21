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
require 'extensions.rb'

module Sketchup::Samples
module Shapes

# Create the extension.
shapes_ext = SketchupExtension.new 'Shapes Tool', 'su_shapes/shapes.rb'
shapes_ext.description = 'Shapes sample script from SketchUp.com'
shapes_ext.version =  '1.1.1'
shapes_ext.creator = "SketchUp"
shapes_ext.copyright = "2014, Trimble Navigation Limited"

# Register the extension with Sketchup so it show up in the Preference panel.
Sketchup.register_extension shapes_ext, true

end # module Shapes
end # module Sketchup::Samples
