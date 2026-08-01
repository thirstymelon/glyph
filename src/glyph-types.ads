------------------------------------------------------------------------------
--  Glyph.Types
--
--  Fundamental types for coordinates, points, lines, rects, dimensions,
--  colors, scalars, and raw byte arrays.
------------------------------------------------------------------------------

package Glyph.Types is

   type Coordinate is range -32_768 .. 32_767;
   type Dimension is range 0 .. 32_767;

   --  Standard floating-point scalar for graphics algorithms
   subtype Real is Float;

   --  2D Point
   type Point is record
      X : Coordinate := 0;
      Y : Coordinate := 0;
   end record;

   --  2D Line Segment
   type Line is record
      Start_Point : Point;
      End_Point   : Point;
   end record;

   --  2D Axis-Aligned Bounding Box / Clipping Rectangle
   type Rect is record
      Min_Point : Point;
      Max_Point : Point;
   end record;

   type Pixel_Color is (Off, On, Invert);

   type Byte is mod 2 ** 8;
   for Byte'Size use 8;

   type Byte_Array is array (Positive range <>) of Byte;
   pragma Pack (Byte_Array);

end Glyph.Types;
