------------------------------------------------------------------------------
--  Glyph.Algorithms.Bresenham
--
--  Implementation of zero-cost generic Bresenham 2D line algorithm.
------------------------------------------------------------------------------

package body Glyph.Algorithms.Bresenham is

   ---------------------------------------------------------------------------
   --  Generic Bresenham Line Rasterizer Implementation
   ---------------------------------------------------------------------------
   procedure Plot_Line (Target_Line : Line) is
      X1 : Coordinate := Target_Line.Start_Point.X;
      Y1 : Coordinate := Target_Line.Start_Point.Y;
      X2 : constant Coordinate := Target_Line.End_Point.X;
      Y2 : constant Coordinate := Target_Line.End_Point.Y;

      DX : constant Coordinate := abs (X2 - X1);
      DY : constant Coordinate := abs (Y2 - Y1);

      SX : constant Coordinate := (if X1 < X2 then 1 else -1);
      SY : constant Coordinate := (if Y1 < Y2 then 1 else -1);

      Err : Coordinate := DX - DY;
      E2  : Coordinate;

   begin
      loop
         Put_Pixel (X1, Y1);

         exit when X1 = X2 and then Y1 = Y2;

         E2 := 2 * Err;

         if E2 > -DY then
            Err := Err - DY;
            X1 := X1 + SX;
         end if;

         if E2 < DX then
            Err := Err + DX;
            Y1 := Y1 + SY;
         end if;
      end loop;

   end Plot_Line;

end Glyph.Algorithms.Bresenham;
