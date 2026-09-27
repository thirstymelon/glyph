with Glyph.Types;

package Glyph.Algorithms.Triangle is

   generic
      with
        procedure Draw_Line (Line : Glyph.Types.Line);
   procedure Rasterize_Triangle (Tri : Glyph.Types.Triangle);

   generic
      with
        procedure Fill_Row
          (X_Start : Glyph.Types.Coordinate;
           X_End   : Glyph.Types.Coordinate;
           Y       : Glyph.Types.Coordinate);
   procedure Rasterize_Filled_Triangle
     (Tri   : Glyph.Types.Triangle;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate);

end Glyph.Algorithms.Triangle;
