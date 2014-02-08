# Copyright 2014 Trimble Navigation Ltd.
#
# License: The MIT License (MIT)
#
# A SketchUp Ruby Extension that creates simple shape objects.  More info at  
# https://github.com/SketchUp/shapes
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

require "sketchup.rb"
require "extensions.rb"

module Sketchup::Samples
module Shapes

# Create the extension.
shapes_ext = SketchupExtension.new "Shapes Tool", "su_shapes/shapes.rb"
shapes_ext.description = "Shapes sample script from SketchUp.com"
shapes_ext.version =  "1.4.4"
shapes_ext.creator = "SketchUp"
shapes_ext.copyright = "2014, Trimble Navigation Limited"

# Register the extension with Sketchup so it show up in the Preference panel.
Sketchup.register_extension shapes_ext, true

end # module Shapes
end # module Sketchup::Samples
