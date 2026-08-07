package body Glyph.Algorithms.Rectangle is

   procedure Plot_HLine
     (X_Start : Coordinate; X_End : Coordinate; Y : Coordinate) is
   begin
      for X in X_Start .. X_End loop
         Put_Pixel (X, Y);
      end loop;
   end Plot_HLine;

   procedure Plot_VLine
     (X : Coordinate; Y_Start : Coordinate; Y_End : Coordinate) is
   begin
      for Y in Y_Start .. Y_End loop
         Put_Pixel (X, Y);
      end loop;
   end Plot_VLine;

   type Rectangle_Edges is record
      Left_X   : Coordinate;
      Right_X  : Coordinate;
      Top_Y    : Coordinate;
      Bottom_Y : Coordinate;
   end record;

   function Normalize (Area : Glyph.Types.Rect) return Rectangle_Edges is
   begin
      return
        (Left_X   => Coordinate'Min (Area.Min_Point.X, Area.Max_Point.X),
         Right_X  => Coordinate'Max (Area.Min_Point.X, Area.Max_Point.X),
         Top_Y    => Coordinate'Min (Area.Min_Point.Y, Area.Max_Point.Y),
         Bottom_Y => Coordinate'Max (Area.Min_Point.Y, Area.Max_Point.Y));
   end Normalize;

   procedure Draw (Area : Glyph.Types.Rect) is
      R : constant Rectangle_Edges := Normalize (Area);
   begin
      Plot_HLine (R.Left_X, R.Right_X, R.Top_Y);
      Plot_HLine (R.Left_X, R.Right_X, R.Bottom_Y);
      Plot_VLine (R.Left_X, R.Top_Y, R.Bottom_Y);
      Plot_VLine (R.Right_X, R.Top_Y, R.Bottom_Y);
   end Draw;

   procedure Fill (Area : Glyph.Types.Rect) is
      R : constant Rectangle_Edges := Normalize (Area);
   begin
      for Y in R.Top_Y .. R.Bottom_Y loop
         Plot_HLine (R.Left_X, R.Right_X, Y);
      end loop;
   end Fill;

end Glyph.Algorithms.Rectangle;
