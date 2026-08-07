with Glyph.Algorithms.Rectangle;

separate (Glyph.Canvas)

procedure Glow_Rectangle
  (Self : in out Drawing_Canvas; Area : Rect; Color : Pixel_Color)
is

   procedure Plot_Canvas_Pixel (X, Y : Coordinate) is
   begin
      Self.Glow_Pixel (X, Y, Color);
   end Plot_Canvas_Pixel;

   package Rectangle is new
     Glyph.Algorithms.Rectangle (Put_Pixel => Plot_Canvas_Pixel);

begin
   Rectangle.Draw (Area);
end Glow_Rectangle;
