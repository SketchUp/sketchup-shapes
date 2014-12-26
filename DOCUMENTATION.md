#Draw Parametric Shapes v2.2
© Trimble Navigation Ltd Sketchup Team and John McClenahan 2014
##Purpose
This plugin enables Sketchup users to draw and subsequently edit a range of common
geometric 3D shapes by specifying in a dialogue box their size and (where relevant) the 
number of segments to use when drawing circles or polygons.

It has been tested on Windows 7 Pro and Sketchup v8, 2013 and 2014, but should
work on earlier versions of Sketchup, on Windows XP or later. I have no way of testing it on
a Mac. Language is English only.

The plugin installs a 3D Shapes sub-menu in the standard Sketchup Draw menu, with a selection
of shapes to choose from:

- Box
- Cylinder
- Cone
- Torus
- Tube
- Prism
- Pyramid
- Dome
- Sphere
- Helix
- Helical Ramp
- Helical Ramp with Sides

Edit the parameters to the desired size and (where relevant) number of segments or sides to
use, and click [OK]. The shape is then drawn located at the axis origin [0,0,0] as a Group.

The drawn shape can be undone in one operation using Ctrl+Z or Alt+Backspace keyboard
shortcut, or using the Edit/Undo menu, or once undone, can be re-done by using the menu
Edit/Redo/_Shape Name_, or Ctrl+Y immediately, before issuing any other command.

When any previously drawn Shape is selected, a right-click Context menu (Edit _Shape Name_)
allows the user to change any of its defining parameters using a pop-up dialogue.

The plugin uses two other Ruby scripts – parametric.rb and mesh_additions.rb – which are
included in the .rbz plugin file and automatically installed along with the shapes.rb file.

###Additions to original v1
Additions extend the original v1 Trimble Sketchup Team plugin to provide:

- Four additional shapes – Sphere, Helix, Helical Ramp, and Helical Ramp with Sides.

Additional options:

- User selection of the number of segments to use when drawing shapes based on a circle,
  not just a fixed default (usually 24 in the original plugin).
- Pyramid with any number of sides in its base polygon, not just a square base
- Default sizes remembered from the previous use of that shape.
- Initial default sizes on first use of a shape selected according to the model units and
  unit format, usually one unit for length, height, width, depth or radius (when units are feet, inches or
  metres) or 10 units (for millimetre and centimetre units).
- Initial default number of segments to draw set at 16 for most shapes, and a matching 4 per 90
  degrees for Dome or Sphere. It can be changed by the user (and will be remembered for
  the duration of the SketchUp session).
- Helical Shapes can be drawn with positive or negative pitch - negative pitch goes down.
- Helical Shapes can be drawn with fractional values for Number of Rotations.
- Helical Shapes can be drawn with option to start at specified angle from X-axis 
- A negative value for No of Rotations draws a left-handed helix or helical shape
- Helical Ramp can have different widths at start and end, and start at optional angle from X-axis.
- Helical Ramp with Sides, with additional option for angle of slope of sides.

The appearance of Helical Ramp with Sides can be altered by R-click, Smooth/Soften Edges, and adjusting the smooth parameters. The default softens the top edges and joins between faces.

NOTE: To make a permanent change to the initial default number of segments, edit the *shapes.rb*
file *default_parameters* method for each shape Class, and change the line @@segments = 16 to
your desired default.

For support, email john.mcclenahan@gmail.com, or raise an issue on GitHub [https://github.com/johnwmcc/sketchup-shapes](https://github.com/johnwmcc/sketchup-shapes) 
