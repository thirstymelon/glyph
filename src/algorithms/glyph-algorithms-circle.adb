package body Glyph.Algorithms.Circle is

   Sin_Table : constant array (0 .. 90) of Integer :=
     (0   => 0,    1   => 17,   2   => 35,   3   => 52,   4   => 70,
      5   => 87,   6   => 105,  7   => 122,  8   => 139,  9   => 156,
      10  => 174,  11  => 191,  12  => 208,  13  => 225,  14  => 242,
      15  => 259,  16  => 276,  17  => 292,  18  => 309,  19  => 326,
      20  => 342,  21  => 358,  22  => 375,  23  => 391,  24  => 407,
      25  => 423,  26  => 438,  27  => 454,  28  => 469,  29  => 485,
      30  => 500,  31  => 515,  32  => 530,  33  => 545,  34  => 559,
      35  => 574,  36  => 588,  37  => 602,  38  => 616,  39  => 629,
      40  => 643,  41  => 656,  42  => 669,  43  => 682,  44  => 695,
      45  => 707,  46  => 719,  47  => 731,  48  => 743,  49  => 755,
      50  => 766,  51  => 777,  52  => 788,  53  => 799,  54  => 809,
      55  => 819,  56  => 829,  57  => 839,  58  => 848,  59  => 857,
      60  => 866,  61  => 875,  62  => 883,  63  => 891,  64  => 899,
      65  => 906,  66  => 914,  67  => 921,  68  => 927,  69  => 934,
      70  => 940,  71  => 946,  72  => 951,  73  => 956,  74  => 961,
      75  => 966,  76  => 970,  77  => 974,  78  => 978,  79  => 982,
      80  => 985,  81  => 988,  82  => 990,  83  => 993,  84  => 995,
      85  => 996,  86  => 998,  87  => 999,  88  => 999,  89  => 1000,
      90  => 1000);

   function ISin (Deg : Integer) return Integer is
      Norm : constant Natural := Natural (((Deg mod 360) + 360) mod 360);
   begin
      if Norm <= 90 then
         return Sin_Table (Norm);
      elsif Norm <= 180 then
         return Sin_Table (180 - Norm);
      elsif Norm <= 270 then
         return -Sin_Table (Norm - 180);
      else
         return -Sin_Table (360 - Norm);
      end if;
   end ISin;

   function ICos (Deg : Integer) return Integer is
   begin
      return ISin (Deg + 90);
   end ICos;

   function Angle_In_Sweep
     (DX, DY       : Integer;
      V1_X, V1_Y   : Integer;
      V2_X, V2_Y   : Integer;
      Sweep        : Integer) return Boolean is
      Cross1 : constant Integer := V1_X * DY - V1_Y * DX;
      Cross2 : constant Integer := DX * V2_Y - DY * V2_X;
   begin
      if DX = 0 and then DY = 0 then
         return True;
      end if;

      if Sweep <= 180 then
         return Cross1 >= 0 and then Cross2 >= 0;
      else
         return Cross1 >= 0 or else Cross2 >= 0;
      end if;
   end Angle_In_Sweep;

   procedure Rasterize_Circle
     (Circle : Glyph.Types.Circle;
      X_Max  : Glyph.Types.Coordinate;
      Y_Max  : Glyph.Types.Coordinate)
   is
      use Glyph.Types;
      X0 : constant Coordinate := Circle.Center.X;
      Y0 : constant Coordinate := Circle.Center.Y;
      R  : constant Coordinate := Coordinate (Circle.Radius);

      procedure Draw_Point (PX, PY : Coordinate) is
      begin
         if PX >= 0 and then PX <= X_Max and then PY >= 0 and then PY <= Y_Max then
            Plot (PX, PY);
         end if;
      end Draw_Point;

      procedure Plot_Symmetric (Cur_X, Cur_Y : Coordinate) is
      begin
         Draw_Point (X0 + Cur_X, Y0 + Cur_Y);
         if Cur_X /= 0 then
            Draw_Point (X0 - Cur_X, Y0 + Cur_Y);
         end if;
         if Cur_Y /= 0 then
            Draw_Point (X0 + Cur_X, Y0 - Cur_Y);
         end if;
         if Cur_X /= 0 and then Cur_Y /= 0 then
            Draw_Point (X0 - Cur_X, Y0 - Cur_Y);
         end if;

         if Cur_X /= Cur_Y then
            Draw_Point (X0 + Cur_Y, Y0 + Cur_X);
            if Cur_Y /= 0 then
               Draw_Point (X0 - Cur_Y, Y0 + Cur_X);
            end if;
            if Cur_X /= 0 then
               Draw_Point (X0 + Cur_Y, Y0 - Cur_X);
            end if;
            if Cur_X /= 0 and then Cur_Y /= 0 then
               Draw_Point (X0 - Cur_Y, Y0 - Cur_X);
            end if;
         end if;
      end Plot_Symmetric;

      X : Coordinate := 0;
      Y : Coordinate := R;
      D : Coordinate := 3 - 2 * R;

   begin
      if Circle.Radius = 0 then
         Draw_Point (X0, Y0);
         return;
      end if;

      while X <= Y loop
         Plot_Symmetric (X, Y);
         if D <= 0 then
            D := D + 4 * X + 6;
         else
            D := D + 4 * (X - Y) + 10;
            Y := Y - 1;
         end if;
         X := X + 1;
      end loop;
   end Rasterize_Circle;

   procedure Rasterize_Filled_Circle
     (Circle : Glyph.Types.Circle;
      X_Max  : Glyph.Types.Coordinate;
      Y_Max  : Glyph.Types.Coordinate)
   is
      use Glyph.Types;
      X0 : constant Coordinate := Circle.Center.X;
      Y0 : constant Coordinate := Circle.Center.Y;
      R  : constant Coordinate := Coordinate (Circle.Radius);

      procedure Draw_Row (X_Start, X_End, Y : Coordinate) is
         Clamped_X_Start : Coordinate;
         Clamped_X_End   : Coordinate;
      begin
         if Y >= 0 and then Y <= Y_Max then
            Clamped_X_Start := Coordinate'Max (0, X_Start);
            Clamped_X_End   := Coordinate'Min (X_Max, X_End);
            if Clamped_X_Start <= Clamped_X_End then
               Fill_Row (Clamped_X_Start, Clamped_X_End, Y);
            end if;
         end if;
      end Draw_Row;

      X : Coordinate := 0;
      Y : Coordinate := R;
      D : Coordinate := 3 - 2 * R;

   begin
      if Circle.Radius = 0 then
         Draw_Row (X0, X0, Y0);
         return;
      end if;

      while X <= Y loop
         Draw_Row (X0 - Y, X0 + Y, Y0 + X);
         if X /= 0 then
            Draw_Row (X0 - Y, X0 + Y, Y0 - X);
         end if;

         if D > 0 then
            if X /= Y then
               Draw_Row (X0 - X, X0 + X, Y0 + Y);
               Draw_Row (X0 - X, X0 + X, Y0 - Y);
            end if;
            D := D + 4 * (X - Y) + 10;
            Y := Y - 1;
         else
            D := D + 4 * X + 6;
         end if;
         X := X + 1;
      end loop;
   end Rasterize_Filled_Circle;

   procedure Rasterize_Arc
     (Center_X    : Glyph.Types.Coordinate;
      Center_Y    : Glyph.Types.Coordinate;
      Radius      : Glyph.Types.Dimension;
      Start_Angle : Integer;
      End_Angle   : Integer;
      X_Max       : Glyph.Types.Coordinate;
      Y_Max       : Glyph.Types.Coordinate)
   is
      use Glyph.Types;
      R : constant Coordinate := Coordinate (Radius);

      Norm_Start : constant Integer := ((Start_Angle mod 360) + 360) mod 360;
      Norm_End   : constant Integer := ((End_Angle mod 360) + 360) mod 360;
      Sweep      : Integer := (Norm_End - Norm_Start) mod 360;

      V1_X : Integer;
      V1_Y : Integer;
      V2_X : Integer;
      V2_Y : Integer;

      procedure Draw_Point (DX, DY : Coordinate) is
         PX : constant Coordinate := Center_X + DX;
         PY : constant Coordinate := Center_Y + DY;
      begin
         if Angle_In_Sweep (DX, DY, V1_X, V1_Y, V2_X, V2_Y, Sweep) then
            if PX >= 0 and then PX <= X_Max and then PY >= 0 and then PY <= Y_Max then
               Plot (PX, PY);
            end if;
         end if;
      end Draw_Point;

      procedure Plot_Symmetric (Cur_X, Cur_Y : Coordinate) is
      begin
         Draw_Point (Cur_X, Cur_Y);
         if Cur_X /= 0 then
            Draw_Point (-Cur_X, Cur_Y);
         end if;
         if Cur_Y /= 0 then
            Draw_Point (Cur_X, -Cur_Y);
         end if;
         if Cur_X /= 0 and then Cur_Y /= 0 then
            Draw_Point (-Cur_X, -Cur_Y);
         end if;

         if Cur_X /= Cur_Y then
            Draw_Point (Cur_Y, Cur_X);
            if Cur_Y /= 0 then
               Draw_Point (-Cur_Y, Cur_X);
            end if;
            if Cur_X /= 0 then
               Draw_Point (Cur_Y, -Cur_X);
            end if;
            if Cur_X /= 0 and then Cur_Y /= 0 then
               Draw_Point (-Cur_Y, -Cur_X);
            end if;
         end if;
      end Plot_Symmetric;

      X : Coordinate := 0;
      Y : Coordinate := R;
      D : Coordinate := 3 - 2 * R;

   begin
      if Radius = 0 then
         if Center_X >= 0 and then Center_X <= X_Max and then
            Center_Y >= 0 and then Center_Y <= Y_Max then
            Plot (Center_X, Center_Y);
         end if;
         return;
      end if;

      if Sweep = 0 and then Start_Angle /= End_Angle then
         Sweep := 360;
      end if;

      if Sweep = 0 then
         return;
      end if;

      V1_X := ICos (Norm_Start);
      V1_Y := ISin (Norm_Start);
      V2_X := ICos (Norm_End);
      V2_Y := ISin (Norm_End);

      while X <= Y loop
         Plot_Symmetric (X, Y);
         if D <= 0 then
            D := D + 4 * X + 6;
         else
            D := D + 4 * (X - Y) + 10;
            Y := Y - 1;
         end if;
         X := X + 1;
      end loop;
   end Rasterize_Arc;

   procedure Rasterize_Sector
     (Center_X    : Glyph.Types.Coordinate;
      Center_Y    : Glyph.Types.Coordinate;
      Radius      : Glyph.Types.Dimension;
      Start_Angle : Integer;
      End_Angle   : Integer;
      X_Max       : Glyph.Types.Coordinate;
      Y_Max       : Glyph.Types.Coordinate)
   is
      use Glyph.Types;
      procedure Draw_Arc is new Rasterize_Arc (Plot => Plot);

      Norm_Start : constant Integer := ((Start_Angle mod 360) + 360) mod 360;
      Norm_End   : constant Integer := ((End_Angle mod 360) + 360) mod 360;
      Sweep      : Integer := (Norm_End - Norm_Start) mod 360;

      X1, Y1 : Coordinate;
      X2, Y2 : Coordinate;

   begin
      if Sweep = 0 and then Start_Angle /= End_Angle then
         Sweep := 360;
      end if;

      Draw_Arc
        (Center_X    => Center_X,
         Center_Y    => Center_Y,
         Radius      => Radius,
         Start_Angle => Start_Angle,
         End_Angle   => End_Angle,
         X_Max       => X_Max,
         Y_Max       => Y_Max);

      if Sweep > 0 and then Sweep < 360 and then Radius > 0 then
         X1 := Center_X + Coordinate ((Integer (Radius) * ICos (Norm_Start) + 500) / 1000);
         Y1 := Center_Y + Coordinate ((Integer (Radius) * ISin (Norm_Start) + 500) / 1000);
         X2 := Center_X + Coordinate ((Integer (Radius) * ICos (Norm_End) + 500) / 1000);
         Y2 := Center_Y + Coordinate ((Integer (Radius) * ISin (Norm_End) + 500) / 1000);

         Draw_Line ((Start_Point => (Center_X, Center_Y), End_Point => (X1, Y1)));
         Draw_Line ((Start_Point => (Center_X, Center_Y), End_Point => (X2, Y2)));
      end if;
   end Rasterize_Sector;

   procedure Rasterize_Filled_Sector
     (Center_X    : Glyph.Types.Coordinate;
      Center_Y    : Glyph.Types.Coordinate;
      Radius      : Glyph.Types.Dimension;
      Start_Angle : Integer;
      End_Angle   : Integer;
      X_Max       : Glyph.Types.Coordinate;
      Y_Max       : Glyph.Types.Coordinate)
   is
      use Glyph.Types;
      procedure Draw_Full_Circle is new Rasterize_Filled_Circle (Fill_Row => Fill_Row);

      Norm_Start : constant Integer := ((Start_Angle mod 360) + 360) mod 360;
      Norm_End   : constant Integer := ((End_Angle mod 360) + 360) mod 360;
      Sweep      : Integer := (Norm_End - Norm_Start) mod 360;

      V1_X : Integer;
      V1_Y : Integer;
      V2_X : Integer;
      V2_Y : Integer;
      R    : constant Coordinate := Coordinate (Radius);

      In_Span    : Boolean;
      Span_Start : Coordinate;
      PX         : Coordinate;

   begin
      if Sweep = 0 and then Start_Angle /= End_Angle then
         Sweep := 360;
      end if;

      if Sweep = 360 then
         Draw_Full_Circle
           (Circle => (Center => (X => Center_X, Y => Center_Y), Radius => Radius),
            X_Max  => X_Max,
            Y_Max  => Y_Max);
         return;
      end if;

      if Sweep = 0 or else Radius = 0 then
         if Radius = 0 and then Center_X >= 0 and then Center_X <= X_Max and then
            Center_Y >= 0 and then Center_Y <= Y_Max then
            Plot (Center_X, Center_Y);
         end if;
         return;
      end if;

      V1_X := ICos (Norm_Start);
      V1_Y := ISin (Norm_Start);
      V2_X := ICos (Norm_End);
      V2_Y := ISin (Norm_End);

      for DY in -R .. R loop
         declare
            PY     : constant Coordinate := Center_Y + DY;
            DX_Max : Coordinate := 0;
         begin
            if PY >= 0 and then PY <= Y_Max then
               while (DX_Max + 1) * (DX_Max + 1) + DY * DY <= R * R loop
                  DX_Max := DX_Max + 1;
               end loop;

               In_Span := False;
               Span_Start := 0;

               for DX in -DX_Max .. DX_Max loop
                  PX := Center_X + DX;
                  if PX >= 0 and then PX <= X_Max and then
                     Angle_In_Sweep (DX, DY, V1_X, V1_Y, V2_X, V2_Y, Sweep) then
                     if not In_Span then
                        In_Span := True;
                        Span_Start := PX;
                     end if;
                  else
                     if In_Span then
                        Fill_Row (Span_Start, PX - 1, PY);
                        In_Span := False;
                     end if;
                  end if;
               end loop;

               if In_Span then
                  Fill_Row (Span_Start, Coordinate'Min (X_Max, Center_X + DX_Max), PY);
               end if;
            end if;
         end;
      end loop;

   end Rasterize_Filled_Sector;

end Glyph.Algorithms.Circle;
