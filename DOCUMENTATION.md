#Draw Parametric Shapes v2.0
© Trimble Navigation Ltd Sketchup Team and John McClenahan 2014
##Purpose
This plugin enables Sketchup users to draw and subsequently edit a range of common
geometric shapes by specifying in a dialogue box their size and (where relevant) the number
of segments to use when drawing circles or polygons.

It has been tested by on Windows 7 Pro and Sketchup 2013 and 2014, but should
work on earlier versions of Sketchup, on Windows XP or later. I have no way of testing it on
a Mac. Language is English only.

The plugin installs a 3D-Shapes sub-menu in the standard Sketchup Draw menu, with a selection
of shapes chosen from:
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

Edit the parameters to the desired size and (where relevant) number of segments or sides to
use, and click [OK]. The shape is then drawn located at the axis origin [0,0,0] as a Group.

The drawn shape can be undone in one operation using Ctrl+Z or Alt+Backspace keyboard
shortcut, or using the Edit/Undo menu, or once undone, can be re-done by using the menu
Edit/Redo… Shapes, or Ctrl+Y immediately, before issuing any other command.

When any previously drawn Shape is selected, a right-click Context menu (Edit…Shapes)
allows the user to change any of its defining parameters using a pop-up dialogue.

The plugin uses two other Ruby scripts – parametric.rb and mesh_additions.rb – which are
included in the .rbz plugin file and automatically installed along with the shapes.rb file.
###Additions to original v1
Additions extend the original Trimble Sketchup Team plugin to provide:
- An additional shape – Sphere
- User selection of the number of segments to use when drawing shapes based on a circle,
not just a fixed default (usually 24 in the original plugin)
- Drawing a Pyramid with any number of sides in its base polygon, not just a square base
- Default sizes remembered from the previous use of that shape
- Initial default sizes on first use of a shape are selected according to the model units and
unit format, usually one unit for length, height, width, depth or radius (feet, inches or
metres) or for millimetre and centimetre units, 10 units (10 mm or 10 cm).
- The initial default number of segments to draw is set at 16 for most shapes, and 4 per 90
degrees for Dome or Sphere. It can be changed by the user (and will be remembered for
the duration of the Sketchup session).

[To make a permanent change to the initial default number of segments, edit the shapes.rb
file default_parameters method for each shape Class, and change the line @@segments = 16 to
your desired default.]
