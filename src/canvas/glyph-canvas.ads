------------------------------------------------------------------------------
--  Glyph.Canvas
--
--  Drawing surface API. Manipulates the associated Framebuffer.
------------------------------------------------------------------------------

with Glyph.Types; use Glyph.Types;
with Glyph.Framebuffer;

generic
   with package FB is new Glyph.Framebuffer (<>);
package Glyph.Canvas is

   type Drawing_Canvas is tagged limited record
      Buffer     : access FB.Framebuffer;
      Clip_Min_X : Glyph.Types.Coordinate := 0;
      Clip_Min_Y : Glyph.Types.Coordinate := 0;
      Clip_Max_X : Glyph.Types.Coordinate :=
        Glyph.Types.Coordinate (FB.Width - 1);
      Clip_Max_Y : Glyph.Types.Coordinate :=
        Glyph.Types.Coordinate (FB.Height - 1);
   end record;

   procedure Clear (Self : in out Drawing_Canvas);

   procedure Glow_Pixel
     (Self  : in out Drawing_Canvas;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color);

   procedure Glow_Line
     (Self   : in out Drawing_Canvas;
      From_X : Glyph.Types.Coordinate;
      From_Y : Glyph.Types.Coordinate;
      To_X   : Glyph.Types.Coordinate;
      To_Y   : Glyph.Types.Coordinate;
      Color  : Glyph.Types.Pixel_Color);

end Glyph.Canvas;
