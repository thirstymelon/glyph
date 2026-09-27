package body Glyph.Algorithms.Rectangle is

   procedure Rasterize_Rectangle
     (Rect  : Glyph.Types.Rectangle;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate)
   is
      use Glyph.Types;
   begin
      if Rect.Width = 0 or else Rect.Height = 0 then
         return;
      end if;

      declare
         X1 : constant Coordinate := Rect.X + Coordinate (Rect.Width) - 1;
         Y1 : constant Coordinate := Rect.Y + Coordinate (Rect.Height) - 1;
      begin
         if Rect.Y >= 0 and then Rect.Y <= Y_Max then
            Plot_Horizontal_Span
              (X_Start => Coordinate'Max (0, Rect.X),
               X_End   => Coordinate'Min (X_Max, X1),
               Y       => Rect.Y);
         end if;

         if Y1 >= 0 and then Y1 <= Y_Max and then Y1 /= Rect.Y then
            Plot_Horizontal_Span
              (X_Start => Coordinate'Max (0, Rect.X),
               X_End   => Coordinate'Min (X_Max, X1),
               Y       => Y1);
         end if;

         if Rect.X >= 0 and then Rect.X <= X_Max then
            Plot_Vertical_Span
              (Y_Start => Coordinate'Max (0, Rect.Y),
               Y_End   => Coordinate'Min (Y_Max, Y1),
               X       => Rect.X);
         end if;

         if X1 >= 0 and then X1 <= X_Max and then X1 /= Rect.X then
            Plot_Vertical_Span
              (Y_Start => Coordinate'Max (0, Rect.Y),
               Y_End   => Coordinate'Min (Y_Max, Y1),
               X       => X1);
         end if;
      end;
   end Rasterize_Rectangle;

   procedure Rasterize_Filled_Rectangle
     (Rect  : Glyph.Types.Rectangle;
      X_Max : Glyph.Types.Coordinate;
      Y_Max : Glyph.Types.Coordinate)
   is
      use Glyph.Types;
   begin
      if Rect.Width = 0 or else Rect.Height = 0 then
         return;
      end if;

      declare
         X_Start : constant Coordinate := Coordinate'Max (0, Rect.X);
         X_End   : constant Coordinate :=
           Coordinate'Min (X_Max, Rect.X + Coordinate (Rect.Width) - 1);
         Y_Start : constant Coordinate := Coordinate'Max (0, Rect.Y);
         Y_End   : constant Coordinate :=
           Coordinate'Min (Y_Max, Rect.Y + Coordinate (Rect.Height) - 1);
      begin
         if X_Start <= X_End and then Y_Start <= Y_End then
            for Y in Y_Start .. Y_End loop
               Fill_Row (X_Start, X_End, Y);
            end loop;
         end if;
      end;
   end Rasterize_Filled_Rectangle;

end Glyph.Algorithms.Rectangle;
