package body Glyph.Algorithms.Clipping is

   type Outcode is mod 16;

   INSIDE : constant Outcode := 0;
   LEFT   : constant Outcode := 1;
   RIGHT  : constant Outcode := 2;
   BOTTOM : constant Outcode := 4;
   TOP    : constant Outcode := 8;

   function Clip_Line
     (Line  : Glyph.Types.Line;
      X_Min : Glyph.Types.Coordinate;
      Y_Min : Glyph.Types.Coordinate;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate) return Clip_Result
   is
      use Glyph.Types;

      function Compute_Code (P : Point) return Outcode is
         Code : Outcode := INSIDE;
      begin
         if P.X < X_Min then
            Code := Code or LEFT;
         elsif P.X > X_Max then
            Code := Code or RIGHT;
         end if;

         if P.Y < Y_Min then
            Code := Code or TOP;
         elsif P.Y > Y_Max then
            Code := Code or BOTTOM;
         end if;
         return Code;
      end Compute_Code;

      P0 : Point := Line.Start_Point;
      P1 : Point := Line.End_Point;

      Code_0 : Outcode := Compute_Code (P0);
      Code_1 : Outcode := Compute_Code (P1);

      Accepted : Boolean := False;
      Out_Code : Outcode;
      X, Y     : Coordinate;

   begin
      loop
         if (Code_0 or Code_1) = 0 then
            Accepted := True;
            exit;
         elsif (Code_0 and Code_1) /= 0 then
            exit;
         else
            Out_Code := (if Code_0 /= 0 then Code_0 else Code_1);

            if (Out_Code and TOP) /= 0 then
               if P1.Y /= P0.Y then
                  X := Coordinate
                    (Long_Integer (P0.X) +
                     (Long_Integer (P1.X) - Long_Integer (P0.X)) *
                     (Long_Integer (Y_Min) - Long_Integer (P0.Y)) /
                     (Long_Integer (P1.Y) - Long_Integer (P0.Y)));
               else
                  X := P0.X;
               end if;
               Y := Y_Min;
            elsif (Out_Code and BOTTOM) /= 0 then
               if P1.Y /= P0.Y then
                  X := Coordinate
                    (Long_Integer (P0.X) +
                     (Long_Integer (P1.X) - Long_Integer (P0.X)) *
                     (Long_Integer (Y_Max) - Long_Integer (P0.Y)) /
                     (Long_Integer (P1.Y) - Long_Integer (P0.Y)));
               else
                  X := P0.X;
               end if;
               Y := Y_Max;
            elsif (Out_Code and RIGHT) /= 0 then
               if P1.X /= P0.X then
                  Y := Coordinate
                    (Long_Integer (P0.Y) +
                     (Long_Integer (P1.Y) - Long_Integer (P0.Y)) *
                     (Long_Integer (X_Max) - Long_Integer (P0.X)) /
                     (Long_Integer (P1.X) - Long_Integer (P0.X)));
               else
                  Y := P0.Y;
               end if;
               X := X_Max;
            elsif (Out_Code and LEFT) /= 0 then
               if P1.X /= P0.X then
                  Y := Coordinate
                    (Long_Integer (P0.Y) +
                     (Long_Integer (P1.Y) - Long_Integer (P0.Y)) *
                     (Long_Integer (X_Min) - Long_Integer (P0.X)) /
                     (Long_Integer (P1.X) - Long_Integer (P0.X)));
               else
                  Y := P0.Y;
               end if;
               X := X_Min;
            else
               exit;
            end if;

            if Out_Code = Code_0 then
               P0.X := X;
               P0.Y := Y;
               Code_0 := Compute_Code (P0);
            else
               P1.X := X;
               P1.Y := Y;
               Code_1 := Compute_Code (P1);
            end if;
         end if;
      end loop;

      if Accepted then
         return
           (Visible => True,
            Clipped => (Start_Point => P0, End_Point => P1));
      else
         return (Visible => False, Clipped => Line);
      end if;
   end Clip_Line;

end Glyph.Algorithms.Clipping;
