# Copyright 2014, Trimble Navigation Limited

# This software is provided as an example of using the Ruby interface
# to SketchUp.

# Permission to use, copy, modify, and distribute this software for
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.

# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
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
