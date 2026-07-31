------------------------------------------------------------------------------
--  Glyph.Canvas
--
--  Implementation of canvas drawing operations and clipping bounds.
------------------------------------------------------------------------------

package body Glyph.Canvas is

   procedure Clear (Self : in out Drawing_Canvas) is
   begin
      Self.Buffer.Clear;
   end Clear;

   procedure Draw_Pixel
     (Self  : in out Drawing_Canvas;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color) is
   begin
      -- Apply Canvas clipping rectangle bounds
      if X >= Self.Clip_Min_X and X <= Self.Clip_Max_X and
         Y >= Self.Clip_Min_Y and Y <= Self.Clip_Max_Y
      then
         Self.Buffer.Set_Pixel (X, Y, Color);
      end if;
   end Draw_Pixel;

end Glyph.Canvas;
