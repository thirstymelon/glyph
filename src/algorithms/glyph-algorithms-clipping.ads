with Glyph.Types;

package Glyph.Algorithms.Clipping is

   type Clip_Result is record
      Visible : Boolean;
      Clipped : Glyph.Types.Line;
   end record;

   function Clip_Line
     (Line  : Glyph.Types.Line;
      X_Min : Glyph.Types.Coordinate;
      Y_Min : Glyph.Types.Coordinate;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate) return Clip_Result;

end Glyph.Algorithms.Clipping;
