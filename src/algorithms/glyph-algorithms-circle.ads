with Glyph.Types;

package Glyph.Algorithms.Circle is

   function ISin (Deg : Integer) return Integer;
   function ICos (Deg : Integer) return Integer;

   generic
      with
        procedure Plot
          (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate);
   procedure Rasterize_Circle
     (Circle : Glyph.Types.Circle;
      X_Max  : Glyph.Types.Coordinate;
      Y_Max  : Glyph.Types.Coordinate);

   generic
      with
        procedure Fill_Row
          (X_Start : Glyph.Types.Coordinate;
           X_End   : Glyph.Types.Coordinate;
           Y       : Glyph.Types.Coordinate);
   procedure Rasterize_Filled_Circle
     (Circle : Glyph.Types.Circle;
      X_Max  : Glyph.Types.Coordinate;
      Y_Max  : Glyph.Types.Coordinate);

   generic
      with
        procedure Plot
          (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate);
   procedure Rasterize_Arc
     (Center_X    : Glyph.Types.Coordinate;
      Center_Y    : Glyph.Types.Coordinate;
      Radius      : Glyph.Types.Dimension;
      Start_Angle : Integer;
      End_Angle   : Integer;
      X_Max       : Glyph.Types.Coordinate;
      Y_Max       : Glyph.Types.Coordinate);

   generic
      with
        procedure Plot
          (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate);
      with procedure Draw_Line (Line : Glyph.Types.Line);
   procedure Rasterize_Sector
     (Center_X    : Glyph.Types.Coordinate;
      Center_Y    : Glyph.Types.Coordinate;
      Radius      : Glyph.Types.Dimension;
      Start_Angle : Integer;
      End_Angle   : Integer;
      X_Max       : Glyph.Types.Coordinate;
      Y_Max       : Glyph.Types.Coordinate);

   generic
      with
        procedure Plot
          (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate);
      with
        procedure Fill_Row
          (X_Start : Glyph.Types.Coordinate;
           X_End   : Glyph.Types.Coordinate;
           Y       : Glyph.Types.Coordinate);
   procedure Rasterize_Filled_Sector
     (Center_X    : Glyph.Types.Coordinate;
      Center_Y    : Glyph.Types.Coordinate;
      Radius      : Glyph.Types.Dimension;
      Start_Angle : Integer;
      End_Angle   : Integer;
      X_Max       : Glyph.Types.Coordinate;
      Y_Max       : Glyph.Types.Coordinate);

end Glyph.Algorithms.Circle;
