------------------------------------------------------------------------------
--  Static framebuffer implementation.
--
--  Pixel memory ownership and pixel update operations.
--  Pixel coordinate mapping is delegated to a memory layout package.
------------------------------------------------------------------------------

with Glyph.Types;

generic
   Width : Glyph.Types.Dimension;
   Height : Glyph.Types.Dimension;
package Glyph.Framebuffer is

   Buffer_Size : constant Natural :=
     Natural (Width) * ((Natural (Height) + 7) / 8);

   type Pixel_Buffer is array (1 .. Buffer_Size) of Glyph.Types.Byte;
   pragma Pack (Pixel_Buffer);

   type Framebuffer is tagged limited record
      Data : Pixel_Buffer := (others => 0);
   end record;

   procedure Clear (Self : in out Framebuffer);

   procedure Set_Pixel
     (Self  : in out Framebuffer;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color);

end Glyph.Framebuffer;
