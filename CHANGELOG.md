#Change log for shapes.rb

##v1.1 J W McClenahan 2013-09-14
Added parameter for number of segments to draw for Cylinder, Cone, Torus andTube, replacing fixed n=24.
Changed Box default height 

##v1.2 J W McClenahan 2013-09-15
Added code to detect model length units, and set different default sizes for imperial and metric units 
  in round numbers in each unit system - e.g, substituting 300mm for 1 foot
Tricky bit was finding where to set module-wide values accessible within each class - copied example 
  of points_in_a_circle function to define a function which returns length_unit as a value (now unit_length)

##v1.3 J W McClenahan 2013-09-20
Make initial default sizes one unit in each dimension in model units and format, 
  or simple x10 multiple of one unit (for mm and cm units)
Now remembers last size chosen for shape and presents it as default next time
  Extended Pyramid to n-gon base, not just square base (requires 3 sides or more in base polygon)
  Added Class to construct Sphere as well as Dome.

##v1.4 J W McClenahan 2013-09-22
Redefined torus big radius so it becomes the overall outer radius defaulting to one unit, 
  not as at present where it is the radius to the centre of the smaller radius. 
Amended torus validation check so that small radius must be no more than half outside radius.
Changed small radius default to one quarter outer radius, giving a torus with one half unit central hole

##v1.4.1 J W McClenahan 2013-12-31
Adapting to SU2014 Beta - Ruby changed to v2.0 and shapes.rb crashes - won't load
All lines like: 
  defaults = {"r", 2.feet, "h", 4.feet, "n", 6}  #Original values 
failed with syntax error 
Changed all such lines to the now necessary syntax form, with remembered default values:
  defaults = {"w" => @@dim1, "d" => @@dim2, "h" => @@dim3} 

##v1.4.5 2014-02-14 (modified in stages saved as v1.4.2 ... 1.4.5)
Ruby style cleanup to fix code not in accordance with GitHub Ruby Style Guide
  https://github.com/styleguide/ruby
  including replacing highly abbreviated variable names with more descriptive names

##v1.4.6 2014-02-16
Fixed a few if statements with overlooked parentheses round condition
Replaced the few remaining cryptic abbreviations with more descriptive names
  e1, e2 to edge1, edge2
  pts to points

##v1.5 2014-03-23
Added new Shape - Helix, based on adaptation of Jim Foltz's DrawHelix14.rb, which in turn
was based on Peter Brown's DrawHelix13.rb (2004). The adaptation allows negative Pitch (to draw helix downwards) and/or negative No. of rotations, to draw left hand helix instead of right hand, and adds another editable parameter for the angle at which to start drawing the helix.

##v2.0 2014-03-24
Merged further code clean-up changes from Thomas Thomasson, into version which he will publish on Extension Warehouse

##v2.01 2014-03-24
Added another new shape, Helical Ramp. Still to do: add another parameter so starting and ending ramp width can be different. Also, perhaps, reverse faces if rotations < 0 for left hand helix