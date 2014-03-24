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
    shapes_ext = SketchupExtension.new("Shapes Tool",
      File.join(File.dirname(__FILE__), 'su_shapes', 'shapes.rb'))
    shapes_ext.description = "Shapes sample script from SketchUp.com"
    shapes_ext.version =  "1.4.5"
    shapes_ext.creator = "SketchUp"
    shapes_ext.copyright = "2014, Trimble Navigation Limited and John W McClenahan"

    # Register the extension with Sketchup so it show up in the Preference panel.
    Sketchup.register_extension shapes_ext, true

  end # module Shapes
end # module CommunityExtensions
