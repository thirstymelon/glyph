package body Glyph.Algorithms.Triangle is

   procedure Rasterize_Triangle (Tri : Glyph.Types.Triangle) is
   begin
      Draw_Line ((Start_Point => Tri.A, End_Point => Tri.B));
      Draw_Line ((Start_Point => Tri.B, End_Point => Tri.C));
      Draw_Line ((Start_Point => Tri.C, End_Point => Tri.A));
   end Rasterize_Triangle;

   procedure Rasterize_Filled_Triangle
     (Tri   : Glyph.Types.Triangle;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate)
   is
      use Glyph.Types;

      P0 : Point := Tri.A;
      P1 : Point := Tri.B;
      P2 : Point := Tri.C;
      Temp : Point;

      procedure Swap (A, B : in out Point) is
      begin
         Temp := A;
         A := B;
         B := Temp;
      end Swap;

      procedure Draw_Row (X_Start, X_End, Y : Coordinate) is
         Clamped_X_Start : Coordinate;
         Clamped_X_End   : Coordinate;
      begin
         if Y >= 0 and then Y <= Y_Max then
            Clamped_X_Start := Coordinate'Max (0, Coordinate'Min (X_Start, X_End));
            Clamped_X_End   := Coordinate'Min (X_Max, Coordinate'Max (X_Start, X_End));
            if Clamped_X_Start <= Clamped_X_End then
               Fill_Row (Clamped_X_Start, Clamped_X_End, Y);
            end if;
         end if;
      end Draw_Row;

      Xa, Xb : Coordinate;
      Y_Start, Y_End : Coordinate;

   begin
      if P0.Y > P1.Y then
         Swap (P0, P1);
      end if;
      if P0.Y > P2.Y then
         Swap (P0, P2);
      end if;
      if P1.Y > P2.Y then
         Swap (P1, P2);
      end if;

      if P0.Y = P2.Y then
         Draw_Row
           (X_Start => Coordinate'Min (P0.X, Coordinate'Min (P1.X, P2.X)),
            X_End   => Coordinate'Max (P0.X, Coordinate'Max (P1.X, P2.X)),
            Y       => P0.Y);
         return;
      end if;

      Y_Start := Coordinate'Max (0, P0.Y);
      Y_End   := Coordinate'Min (Y_Max, P2.Y);

      for Y in Y_Start .. Y_End loop
         Xa := P0.X + (Y - P0.Y) * (P2.X - P0.X) / (P2.Y - P0.Y);

         if Y < P1.Y then
            if P1.Y /= P0.Y then
               Xb := P0.X + (Y - P0.Y) * (P1.X - P0.X) / (P1.Y - P0.Y);
            else
               Xb := P0.X;
            end if;
         else
            if P2.Y /= P1.Y then
               Xb := P1.X + (Y - P1.Y) * (P2.X - P1.X) / (P2.Y - P1.Y);
            else
               Xb := P1.X;
            end if;
         end if;

         Draw_Row (Xa, Xb, Y);
      end loop;

   end Rasterize_Filled_Triangle;

end Glyph.Algorithms.Triangle;
