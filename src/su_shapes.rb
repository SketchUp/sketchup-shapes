# Copyright 2014 Trimble Navigation Ltd.
#
# License: The MIT License (MIT)
#
# A SketchUp Ruby Extension that creates simple shape objects.  More info at
# https://github.com/SketchUp/shapes


require "sketchup.rb"
require "extensions.rb"

module CommunityExtensions
  module Shapes

    # Create the extension.
    loader = File.join(File.dirname(__FILE__), "su_shapes", "shapes.rb")
    extension = SketchupExtension.new("Shapes Tool", loader)
    extension.description = "Shapes sample script from SketchUp.com"
    extension.version     = "1.5.0"
    extension.creator     = "SketchUp"
    extension.copyright   = "2014, Trimble Navigation Limited and " <<
                            "John W McClenahan"

    # Register the extension with so it show up in the Preference panel.
    Sketchup.register_extension(extension, true)

  end # module Shapes
end # module CommunityExtensions
