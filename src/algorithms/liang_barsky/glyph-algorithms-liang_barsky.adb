------------------------------------------------------------------------------
--  Glyph.Algorithms.Liang_Barsky
--
--  Implementation of Liang-Barsky line clipping algorithm.
------------------------------------------------------------------------------

package body Glyph.Algorithms.Liang_Barsky is

   type Edge_Index is (Left, Right, Bottom, Top);

   T_Scale : constant Calc := 256;

   type Edge_Array is array (Edge_Index) of Calc;

   function Floor_Divide (Numerator, Denominator : Calc) return Calc is
   begin
      if Denominator < 0 then
         return Floor_Divide (-Numerator, -Denominator);
      elsif Numerator >= 0 then
         return Numerator / Denominator;
      else
         return -((-Numerator + Denominator - 1) / Denominator);
      end if;
   end Floor_Divide;

   function Ceiling_Divide (Numerator, Denominator : Calc) return Calc is
   begin
      return -Floor_Divide (-Numerator, Denominator);
   end Ceiling_Divide;

   function Round_Divide (Numerator, Denominator : Calc) return Calc is
   begin
      if Numerator >= 0 then
         return (Numerator + Denominator / 2) / Denominator;
      else
         return -((-Numerator + Denominator / 2) / Denominator);
      end if;
   end Round_Divide;

   function Clip_Line
     (Target_Line : in out Line; Clip_Rect : Rect) return Boolean
   is

      X1 : constant Calc := Calc (Target_Line.Start_Point.X);
      Y1 : constant Calc := Calc (Target_Line.Start_Point.Y);
      X2 : constant Calc := Calc (Target_Line.End_Point.X);
      Y2 : constant Calc := Calc (Target_Line.End_Point.Y);

      DX : constant Calc := X2 - X1;
      DY : constant Calc := Y2 - Y1;

      P : constant Edge_Array :=
        (Left => -DX, Right => DX, Bottom => -DY, Top => DY);

      Q : constant Edge_Array :=
        (Left   => X1 - Calc (Clip_Rect.Min_Point.X),
         Right  => Calc (Clip_Rect.Max_Point.X) - X1,
         Bottom => Y1 - Calc (Clip_Rect.Min_Point.Y),
         Top    => Calc (Clip_Rect.Max_Point.Y) - Y1);

      U_One : Calc := 0;
      U_Two : Calc := T_Scale;
      R     : Calc;
   begin
      for E in Edge_Index loop
         if P (E) = 0 then
            --  Parallel to this edge; reject if outside.
            if Q (E) < 0 then
               return False;
            end if;

         elsif P (E) < 0 then
            --  Entering edge: round upward.
            R := Ceiling_Divide (Q (E) * T_Scale, P (E));

            if R > U_One then
               U_One := R;
            end if;

         else
            --  Leaving edge: round downward.
            R := Floor_Divide (Q (E) * T_Scale, P (E));

            if R < U_Two then
               U_Two := R;
            end if;
         end if;

         if U_One > U_Two then
            return False;
         end if;
      end loop;

      --  Convert fixed-point t values back to coordinates.
      Target_Line.Start_Point.X :=
        Coordinate (X1 + Round_Divide (DX * U_One, T_Scale));
      Target_Line.Start_Point.Y :=
        Coordinate (Y1 + Round_Divide (DY * U_One, T_Scale));

      Target_Line.End_Point.X :=
        Coordinate (X1 + Round_Divide (DX * U_Two, T_Scale));
      Target_Line.End_Point.Y :=
        Coordinate (Y1 + Round_Divide (DY * U_Two, T_Scale));

      return True;
   end Clip_Line;

end Glyph.Algorithms.Liang_Barsky;
