with Glyph.Types;

package Glyph.Algorithms.Lines with
  SPARK_Mode => On
is

   generic
      with
        procedure Plot
          (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate);
   procedure Rasterize_Line (Line : Glyph.Types.Line);

end Glyph.Algorithms.Lines;
