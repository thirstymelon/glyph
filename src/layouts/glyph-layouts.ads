------------------------------------------------------------------------------
--  Glyph.Layouts
--
--  Common types shared by framebuffer memory layout implementations.
------------------------------------------------------------------------------

package Glyph.Layouts is

   type Pixel_Location is record
      Byte_Index : Positive;
      Bit_Index  : Natural range 0 .. 7;
   end record;

end Glyph.Layouts;
