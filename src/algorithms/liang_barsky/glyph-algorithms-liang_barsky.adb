------------------------------------------------------------------------------
--  Glyph.Algorithms.Liang_Barsky
--
--  Single canonical implementation of Liang-Barsky line clipping algorithm.
------------------------------------------------------------------------------

package body Glyph.Algorithms.Liang_Barsky is

   type Edge_Index is (Left, Right, Bottom, Top);
   type Edge_Array is array (Edge_Index) of Coordinate;

   function Clip_Line
     (Target_Line : in out Line; Clip_Rect : Rect) return Boolean
   is
      dx : constant Coordinate :=
        Target_Line.End_Point.X - Target_Line.Start_Point.X;
      dy : constant Coordinate :=
        Target_Line.End_Point.Y - Target_Line.Start_Point.Y;

      P : constant Edge_Array :=
        (Left => -dx, Right => dx, Bottom => -dy, Top => dy);

      Q : constant Edge_Array :=
        (Left   => Target_Line.Start_Point.X - Clip_Rect.Min_Point.X,
         Right  => Clip_Rect.Max_Point.X - Target_Line.Start_Point.X,
         Bottom => Target_Line.Start_Point.Y - Clip_Rect.Min_Point.Y,
         Top    => Clip_Rect.Max_Point.Y - Target_Line.Start_Point.Y);

      U_One : Real := 0.0;
      U_Two : Real := 1.0;
      R     : Real;

      Orig_Start_X : constant Coordinate := Target_Line.Start_Point.X;
      Orig_Start_Y : constant Coordinate := Target_Line.Start_Point.Y;

   begin
      for E in Edge_Index loop
         if P (E) = 0 then
            --  Line is parallel to edge: if outside clipping box, reject
            if Q (E) < 0 then
               return False;
            end if;
         else
            R := Real (Q (E)) / Real (P (E));

            if P (E) < 0 then
               --  Line is entering edge (pointing inward)
               U_One := Real'Max (U_One, R);
               if U_One > U_Two then
                  return False;
               end if;
            else
               --  Line is leaving edge (pointing outward)
               U_Two := Real'Min (U_Two, R);
               if U_One > U_Two then
                  return False;
               end if;
            end if;
         end if;
      end loop;

      --  Update Target_Line endpoints rounding
      Target_Line.Start_Point.X :=
        Orig_Start_X + Coordinate (Real'Rounding (Real (dx) * U_One));
      Target_Line.Start_Point.Y :=
        Orig_Start_Y + Coordinate (Real'Rounding (Real (dy) * U_One));
      Target_Line.End_Point.X :=
        Orig_Start_X + Coordinate (Real'Rounding (Real (dx) * U_Two));
      Target_Line.End_Point.Y :=
        Orig_Start_Y + Coordinate (Real'Rounding (Real (dy) * U_Two));

      return True;

   end Clip_Line;

end Glyph.Algorithms.Liang_Barsky;
