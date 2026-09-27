with Glyph.Types;

package Glyph.Algorithms.Rectangle is

   generic
      with
        procedure Plot_Horizontal_Span
          (X_Start : Glyph.Types.Coordinate;
           X_End   : Glyph.Types.Coordinate;
           Y       : Glyph.Types.Coordinate);
      with
        procedure Plot_Vertical_Span
          (Y_Start : Glyph.Types.Coordinate;
           Y_End   : Glyph.Types.Coordinate;
           X       : Glyph.Types.Coordinate);
   procedure Rasterize_Rectangle
     (Rect  : Glyph.Types.Rectangle;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate);

   generic
      with
        procedure Fill_Row
          (X_Start : Glyph.Types.Coordinate;
           X_End   : Glyph.Types.Coordinate;
           Y       : Glyph.Types.Coordinate);
   procedure Rasterize_Filled_Rectangle
     (Rect  : Glyph.Types.Rectangle;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate);

end Glyph.Algorithms.Rectangle;
