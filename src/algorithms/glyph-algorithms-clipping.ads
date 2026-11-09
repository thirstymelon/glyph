with Glyph.Types;

package Glyph.Algorithms.Clipping with
  SPARK_Mode => On
is

   type Clip_Result is record
      Visible : Boolean;
      Clipped : Glyph.Types.Line;
   end record;

   function Clip_Line
     (Line  : Glyph.Types.Line;
      X_Min : Glyph.Types.Coordinate;
      Y_Min : Glyph.Types.Coordinate;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate) return Clip_Result with
     Pre  => X_Min <= X_Max and Y_Min <= Y_Max,
     Post => (if Clip_Line'Result.Visible then
                Clip_Line'Result.Clipped.Start_Point.X in X_Min .. X_Max and
                Clip_Line'Result.Clipped.Start_Point.Y in Y_Min .. Y_Max and
                Clip_Line'Result.Clipped.End_Point.X in X_Min .. X_Max and
                Clip_Line'Result.Clipped.End_Point.Y in Y_Min .. Y_Max);

end Glyph.Algorithms.Clipping;
