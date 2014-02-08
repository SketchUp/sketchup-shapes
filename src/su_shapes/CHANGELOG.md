-----------------------------------------------------------------------------
Modified to v1.1 J W McClenahan 2013-09-14
Added parameter for number of segments to draw for Cylinder, Cone, Torus andTube, replacing fixed n=24.
Changed Box default height 
-----------------------------------------------------------------------------
Modified to v1.2 J W McClenahan 2013-09-15
Added code to detect model length units, and set different default sizes for imperial and metric units 
  in round numbers in each unit system - e.g, substituting 300mm for 1 foot
Tricky bit was finding where to set module-wide values accessible within each class - copied example 
  of points_in_a_circle function to define a function which returns length_unit as a value (now unit_length)
-----------------------------------------------------------------------------
Modified to v1.3 J W McClenahan 2013-09-20
Make initial default sizes one unit in each dimension in model units and format, 
  or simple x10 multiple of one unit (for mm and cm units)
Now remembers last size chosen for shape and presents it as default next time
  Extended Pyramid to n-gon base, not just square base (requires 3 sides or more in base polygon)
  Added Class to construct Sphere as well as Dome.
-----------------------------------------------------------------------------
Modified to v1.4 J W McClenahan 2013-09-22
Redefined torus big radius so it becomes the overall outer radius defaulting to one unit, 
  not as at present where it is the radius to the centre of the smaller radius. 
Amended torus validation check so that small radius must be no more than half outside radius.
Changed small radius default to one quarter outer radius, giving a torus with one half unit central hole
-----------------------------------------------------------------------------
Modified to v1.4.1 J W McClenahan 2013-12-31
Adapting to SU2014 Beta - Ruby changed to v2.0 and shapes.rb crashes - won't load
All lines like: 
  defaults = {"r", 2.feet, "h", 4.feet, "n", 6}  #Original values 
failed with syntax error 
Changed all such lines to the now necessary syntax form, with remembered default values:
  defaults = {"w" => @@dim1, "d" => @@dim2, "h" => @@dim3} 
-----------------------------------------------------------------------------