------------------------------------------------------------------------------
--  Glyph.Canvas
--
--  Implementation of canvas drawing operations and clipping bounds.
------------------------------------------------------------------------------

with Glyph.Algorithms.Liang_Barsky;
with Glyph.Algorithms.Bresenham;

package body Glyph.Canvas is

   procedure Clear (Self : in out Drawing_Canvas) is
   begin
      Self.Buffer.Clear;
   end Clear;

   procedure Glow_Pixel
     (Self  : in out Drawing_Canvas;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color) is
   begin

      if X >= Self.Clip_Min_X
        and X <= Self.Clip_Max_X
        and Y >= Self.Clip_Min_Y
        and Y <= Self.Clip_Max_Y
      then
         Self.Buffer.Set_Pixel (X, Y, Color);
      end if;
   end Glow_Pixel;

   procedure Glow_Line
     (Self   : in out Drawing_Canvas;
      From_X : Glyph.Types.Coordinate;
      From_Y : Glyph.Types.Coordinate;
      To_X   : Glyph.Types.Coordinate;
      To_Y   : Glyph.Types.Coordinate;
      Color  : Glyph.Types.Pixel_Color)
   is
      Target_Line : Glyph.Types.Line :=
        (Start_Point => (X => From_X, Y => From_Y),
         End_Point   => (X => To_X, Y => To_Y));

      Clip_Window : constant Glyph.Types.Rect :=
        (Min_Point => (X => Self.Clip_Min_X, Y => Self.Clip_Min_Y),
         Max_Point => (X => Self.Clip_Max_X, Y => Self.Clip_Max_Y));

      -- Local nested procedure calling Glow_Pixel primitive for safety
      procedure Plot_Canvas_Pixel (X, Y : Glyph.Types.Coordinate) is
      begin
         Self.Glow_Pixel (X, Y, Color);
      end Plot_Canvas_Pixel;

      -- Compile-time binding of Bresenham rasterizer
      procedure Draw_Rasterized_Line is new
        Glyph.Algorithms.Bresenham.Plot_Line (Put_Pixel => Plot_Canvas_Pixel);

   begin

      if Glyph.Algorithms.Liang_Barsky.Clip_Line (Target_Line, Clip_Window)
      then

         Draw_Rasterized_Line (Target_Line);
      end if;
   end Glow_Line;

end Glyph.Canvas;
