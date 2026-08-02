------------------------------------------------------------------------------
--  Glyph.Algorithms.Bresenham
--
--  Implementation of Bresenham line rasterization algorithm.
------------------------------------------------------------------------------

package body Glyph.Algorithms.Bresenham is

   procedure Plot_Line (Target_Line : Line) is

      subtype Calc is Integer;

      X1 : Coordinate := Target_Line.Start_Point.X;
      Y1 : Coordinate := Target_Line.Start_Point.Y;
      X2 : constant Coordinate := Target_Line.End_Point.X;
      Y2 : constant Coordinate := Target_Line.End_Point.Y;

      DX : constant Calc := abs (Calc (X2) - Calc (X1));
      DY : constant Calc := abs (Calc (Y2) - Calc (Y1));

      SX : constant Calc := (if X1 < X2 then 1 else -1);
      SY : constant Calc := (if Y1 < Y2 then 1 else -1);

      Err : Calc := DX - DY;
      E2  : Calc;

   begin
      loop
         Put_Pixel (X1, Y1);

         exit when X1 = X2 and then Y1 = Y2;

         E2 := 2 * Err;

         if E2 > -DY then
            Err := Err - DY;
            X1 := Coordinate (Calc (X1) + SX);
         end if;

         if E2 < DX then
            Err := Err + DX;
            Y1 := Coordinate (Calc (Y1) + SY);
         end if;
      end loop;
   end Plot_Line;

end Glyph.Algorithms.Bresenham;
