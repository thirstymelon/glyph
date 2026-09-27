package Glyph.Types is

   subtype Coordinate is Integer;
   subtype Dimension is Natural;
   subtype Angle is Integer;

   type Hemisphere is (Top, Bottom, Left, Right);

   type Point is record
      X : Coordinate;
      Y : Coordinate;
   end record;

   type Size is record
      Width  : Dimension;
      Height : Dimension;
   end record;

   type Line is record
      Start_Point : Point;
      End_Point   : Point;
   end record;

   type Rectangle is record
      X      : Coordinate;
      Y      : Coordinate;
      Width  : Dimension;
      Height : Dimension;
   end record;

   type Circle is record
      Center : Point;
      Radius : Dimension;
   end record;

   type Triangle is record
      A : Point;
      B : Point;
      C : Point;
   end record;

end Glyph.Types;
