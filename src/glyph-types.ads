------------------------------------------------------------------------------
--  Glyph.Types
--
--  Fundamental types for coordinates, dimensions, colors, and raw byte arrays.
------------------------------------------------------------------------------

package Glyph.Types is

   type Coordinate is range -32_768 .. 32_767;
   type Dimension  is range 0 .. 32_767;

   type Pixel_Color is (Off, On, Invert);

   type Byte is mod 2 ** 8;
   for Byte'Size use 8;

   type Byte_Array is array (Positive range <>) of Byte;
   pragma Pack (Byte_Array);

end Glyph.Types;
