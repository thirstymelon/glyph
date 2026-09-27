package body Glyph.Algorithms.Lines is

   procedure Rasterize_Line (Line : Glyph.Types.Line) is
      use Glyph.Types;

      X0 : Coordinate := Line.Start_Point.X;
      Y0 : Coordinate := Line.Start_Point.Y;
      X1 : constant Coordinate := Line.End_Point.X;
      Y1 : constant Coordinate := Line.End_Point.Y;

   begin
      if Y0 = Y1 then
         declare
            Min_X : constant Coordinate := Coordinate'Min (X0, X1);
            Max_X : constant Coordinate := Coordinate'Max (X0, X1);
         begin
            for X in Min_X .. Max_X loop
               Plot (X, Y0);
            end loop;
            return;
         end;
      end if;

      if X0 = X1 then
         declare
            Min_Y : constant Coordinate := Coordinate'Min (Y0, Y1);
            Max_Y : constant Coordinate := Coordinate'Max (Y0, Y1);
         begin
            for Y in Min_Y .. Max_Y loop
               Plot (X0, Y);
            end loop;
            return;
         end;
      end if;

      declare
         DX  : constant Integer := abs Integer (X1 - X0);
         SX  : constant Integer := (if X0 < X1 then 1 else -1);
         DY  : constant Integer := -abs Integer (Y1 - Y0);
         SY  : constant Integer := (if Y0 < Y1 then 1 else -1);
         Err : Integer := DX + DY;
         E2  : Integer;
      begin
         loop
            Plot (X0, Y0);

            exit when X0 = X1 and then Y0 = Y1;

            E2 := 2 * Err;

            if E2 >= DY then
               Err := Err + DY;
               X0  := Coordinate (Integer (X0) + SX);
            end if;

            if E2 <= DX then
               Err := Err + DX;
               Y0  := Coordinate (Integer (Y0) + SY);
            end if;
         end loop;
      end;
   end Rasterize_Line;

end Glyph.Algorithms.Lines;
