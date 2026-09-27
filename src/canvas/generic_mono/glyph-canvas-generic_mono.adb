with Glyph.Algorithms.Clipping;
with Glyph.Algorithms.Lines;
with Glyph.Algorithms.Rectangle;
with Glyph.Algorithms.Circle;
with Glyph.Algorithms.Triangle;

package body Glyph.Canvas.Generic_Mono is

   use type Glyph.Colors.Monochrome;
   use Glyph.Transport;
   use Glyph.Types;

   Max_X : constant Glyph.Types.Coordinate := Glyph.Types.Coordinate (Width - 1);
   Max_Y : constant Glyph.Types.Coordinate := Glyph.Types.Coordinate (Height - 1);

   procedure Clear (Self : in out Instance) is
   begin
      Self.Buffer := (others => (others => Glyph.Colors.Off));
   end Clear;

   procedure Paint_Pixel
     (Self : in out Instance;
      X    : Integer;
      Y    : Integer) is
   begin
      if X >= 0 and then X <= Max_X and then Y >= 0 and then Y <= Max_Y then
         Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
      end if;
   end Paint_Pixel;

   procedure Paint_Line
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer) is
   begin
      Self.Paint_Line
        ((Start_Point => (X => X1, Y => Y1),
          End_Point   => (X => X2, Y => Y2)));
   end Paint_Line;

   procedure Paint_Line
     (Self : in out Instance;
      Line : Glyph.Types.Line)
   is
      Clip : constant Glyph.Algorithms.Clipping.Clip_Result :=
        Glyph.Algorithms.Clipping.Clip_Line
          (Line  => Line,
           X_Min => 0,
           Y_Min => 0,
           X_Max => Max_X,
           Y_Max => Max_Y);

      procedure Plot (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate) is
      begin
         if X >= 0 and then X <= Max_X and then Y >= 0 and then Y <= Max_Y then
            Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
         end if;
      end Plot;

      procedure Draw is new Glyph.Algorithms.Lines.Rasterize_Line (Plot => Plot);

   begin
      if Clip.Visible then
         Draw (Clip.Clipped);
      end if;
   end Paint_Line;

   procedure Paint_Rectangle
     (Self          : in out Instance;
      X, Y          : Integer;
      Width, Height : Integer) is
   begin
      if Width > 0 and then Height > 0 then
         Self.Paint_Rectangle
           ((X      => X,
             Y      => Y,
             Width  => Natural (Width),
             Height => Natural (Height)));
      end if;
   end Paint_Rectangle;

   procedure Paint_Rectangle
     (Self : in out Instance;
      Rect : Glyph.Types.Rectangle)
   is
      procedure H_Span
        (X_Start : Glyph.Types.Coordinate;
         X_End   : Glyph.Types.Coordinate;
         Y       : Glyph.Types.Coordinate) is
      begin
         if Y >= 0 and then Y <= Max_Y then
            for X in Coordinate'Max (0, X_Start) ..
                     Coordinate'Min (Max_X, X_End) loop
               Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
            end loop;
         end if;
      end H_Span;

      procedure V_Span
        (Y_Start : Glyph.Types.Coordinate;
         Y_End   : Glyph.Types.Coordinate;
         X       : Glyph.Types.Coordinate) is
      begin
         if X >= 0 and then X <= Max_X then
            for Y in Coordinate'Max (0, Y_Start) ..
                     Coordinate'Min (Max_Y, Y_End) loop
               Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
            end loop;
         end if;
      end V_Span;

      procedure Draw_Outline is new Glyph.Algorithms.Rectangle.Rasterize_Rectangle
        (Plot_Horizontal_Span => H_Span,
         Plot_Vertical_Span   => V_Span);

   begin
      Draw_Outline (Rect => Rect, X_Max => Max_X, Y_Max => Max_Y);
   end Paint_Rectangle;

   procedure Paint_Filled_Rectangle
     (Self          : in out Instance;
      X, Y          : Integer;
      Width, Height : Integer) is
   begin
      if Width > 0 and then Height > 0 then
         Self.Paint_Filled_Rectangle
           ((X      => X,
             Y      => Y,
             Width  => Natural (Width),
             Height => Natural (Height)));
      end if;
   end Paint_Filled_Rectangle;

   procedure Paint_Filled_Rectangle
     (Self : in out Instance;
      Rect : Glyph.Types.Rectangle)
   is
      procedure Fill_Row
        (X_Start : Glyph.Types.Coordinate;
         X_End   : Glyph.Types.Coordinate;
         Y       : Glyph.Types.Coordinate) is
      begin
         if Y >= 0 and then Y <= Max_Y then
            for X in Coordinate'Max (0, X_Start) ..
                     Coordinate'Min (Max_X, X_End) loop
               Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
            end loop;
         end if;
      end Fill_Row;

      procedure Fill_Box is new Glyph.Algorithms.Rectangle.Rasterize_Filled_Rectangle
        (Fill_Row => Fill_Row);

   begin
      Fill_Box (Rect => Rect, X_Max => Max_X, Y_Max => Max_Y);
   end Paint_Filled_Rectangle;

   procedure Paint_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Start_Angle       : Integer := 0;
      End_Angle         : Integer := 360) is
   begin
      if Radius < 0 then
         return;
      end if;

      declare
         Norm_Start : constant Integer := ((Start_Angle mod 360) + 360) mod 360;
         Norm_End   : constant Integer := ((End_Angle mod 360) + 360) mod 360;
         Sweep      : constant Integer :=
           (if Norm_Start = Norm_End and then Start_Angle /= End_Angle then 360
            else (Norm_End - Norm_Start) mod 360);

         procedure Plot (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate) is
         begin
            if X >= 0 and then X <= Max_X and then Y >= 0 and then Y <= Max_Y then
               Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
            end if;
         end Plot;

         procedure Draw_Line (Line : Glyph.Types.Line) is
         begin
            Self.Paint_Line (Line);
         end Draw_Line;

         procedure Draw_Circle is new Glyph.Algorithms.Circle.Rasterize_Circle
           (Plot => Plot);

         procedure Draw_Sector is new Glyph.Algorithms.Circle.Rasterize_Sector
           (Plot => Plot, Draw_Line => Draw_Line);

      begin
         if Sweep = 360 or else (Start_Angle = 0 and then End_Angle = 360) then
            Draw_Circle
              (Circle => (Center => (X => Center_X, Y => Center_Y), Radius => Natural (Radius)),
               X_Max  => Max_X,
               Y_Max  => Max_Y);
         else
            Draw_Sector
              (Center_X    => Center_X,
               Center_Y    => Center_Y,
               Radius      => Natural (Radius),
               Start_Angle => Start_Angle,
               End_Angle   => End_Angle,
               X_Max       => Max_X,
               Y_Max       => Max_Y);
         end if;
      end;
   end Paint_Circle;

   procedure Paint_Circle
     (Self   : in out Instance;
      Circle : Glyph.Types.Circle) is
   begin
      Self.Paint_Circle
        (Center_X => Circle.Center.X,
         Center_Y => Circle.Center.Y,
         Radius   => Integer (Circle.Radius));
   end Paint_Circle;

   procedure Paint_Filled_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Start_Angle       : Integer := 0;
      End_Angle         : Integer := 360) is
   begin
      if Radius < 0 then
         return;
      end if;

      declare
         Norm_Start : constant Integer := ((Start_Angle mod 360) + 360) mod 360;
         Norm_End   : constant Integer := ((End_Angle mod 360) + 360) mod 360;
         Sweep      : constant Integer :=
           (if Norm_Start = Norm_End and then Start_Angle /= End_Angle then 360
            else (Norm_End - Norm_Start) mod 360);

         procedure Plot (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate) is
         begin
            if X >= 0 and then X <= Max_X and then Y >= 0 and then Y <= Max_Y then
               Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
            end if;
         end Plot;

         procedure Fill_Row
           (X_Start : Glyph.Types.Coordinate;
            X_End   : Glyph.Types.Coordinate;
            Y       : Glyph.Types.Coordinate) is
         begin
            if Y >= 0 and then Y <= Max_Y then
               for X in Coordinate'Max (0, X_Start) ..
                        Coordinate'Min (Max_X, X_End) loop
                  Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
               end loop;
            end if;
         end Fill_Row;

         procedure Draw_Circle is new Glyph.Algorithms.Circle.Rasterize_Filled_Circle
           (Fill_Row => Fill_Row);

         procedure Draw_Sector is new Glyph.Algorithms.Circle.Rasterize_Filled_Sector
           (Plot => Plot, Fill_Row => Fill_Row);

      begin
         if Sweep = 360 or else (Start_Angle = 0 and then End_Angle = 360) then
            Draw_Circle
              (Circle => (Center => (X => Center_X, Y => Center_Y), Radius => Natural (Radius)),
               X_Max  => Max_X,
               Y_Max  => Max_Y);
         else
            Draw_Sector
              (Center_X    => Center_X,
               Center_Y    => Center_Y,
               Radius      => Natural (Radius),
               Start_Angle => Start_Angle,
               End_Angle   => End_Angle,
               X_Max       => Max_X,
               Y_Max       => Max_Y);
         end if;
      end;
   end Paint_Filled_Circle;

   procedure Paint_Filled_Circle
     (Self   : in out Instance;
      Circle : Glyph.Types.Circle) is
   begin
      Self.Paint_Filled_Circle
        (Center_X => Circle.Center.X,
         Center_Y => Circle.Center.Y,
         Radius   => Integer (Circle.Radius));
   end Paint_Filled_Circle;

   procedure Paint_Arc
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Start_Angle       : Integer := 0;
      End_Angle         : Integer := 360) is
   begin
      if Radius < 0 then
         return;
      end if;

      declare
         procedure Plot (X : Glyph.Types.Coordinate; Y : Glyph.Types.Coordinate) is
         begin
            if X >= 0 and then X <= Max_X and then Y >= 0 and then Y <= Max_Y then
               Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
            end if;
         end Plot;

         procedure Draw_Arc is new Glyph.Algorithms.Circle.Rasterize_Arc
           (Plot => Plot);
      begin
         Draw_Arc
           (Center_X    => Center_X,
            Center_Y    => Center_Y,
            Radius      => Natural (Radius),
            Start_Angle => Start_Angle,
            End_Angle   => End_Angle,
            X_Max       => Max_X,
            Y_Max       => Max_Y);
      end;
   end Paint_Arc;

   procedure Paint_Half_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Side              : Glyph.Types.Hemisphere := Glyph.Types.Top) is
   begin
      case Side is
         when Top    => Self.Paint_Circle (Center_X, Center_Y, Radius, 180, 360);
         when Bottom => Self.Paint_Circle (Center_X, Center_Y, Radius, 0, 180);
         when Left   => Self.Paint_Circle (Center_X, Center_Y, Radius, 90, 270);
         when Right  => Self.Paint_Circle (Center_X, Center_Y, Radius, 270, 90);
      end case;
   end Paint_Half_Circle;

   procedure Paint_Filled_Half_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Side              : Glyph.Types.Hemisphere := Glyph.Types.Top) is
   begin
      case Side is
         when Top    => Self.Paint_Filled_Circle (Center_X, Center_Y, Radius, 180, 360);
         when Bottom => Self.Paint_Filled_Circle (Center_X, Center_Y, Radius, 0, 180);
         when Left   => Self.Paint_Filled_Circle (Center_X, Center_Y, Radius, 90, 270);
         when Right  => Self.Paint_Filled_Circle (Center_X, Center_Y, Radius, 270, 90);
      end case;
   end Paint_Filled_Half_Circle;

   procedure Paint_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer) is
   begin
      Self.Paint_Triangle
        ((A => (X => X1, Y => Y1),
          B => (X => X2, Y => Y2),
          C => (X => X3, Y => Y3)));
   end Paint_Triangle;

   procedure Paint_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle)
   is
      procedure Draw_Line (Line : Glyph.Types.Line) is
      begin
         Self.Paint_Line (Line);
      end Draw_Line;

      procedure Draw_Tri is new Glyph.Algorithms.Triangle.Rasterize_Triangle
        (Draw_Line => Draw_Line);

   begin
      Draw_Tri (Tri => Triangle);
   end Paint_Triangle;

   procedure Paint_Filled_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer) is
   begin
      Self.Paint_Filled_Triangle
        ((A => (X => X1, Y => Y1),
          B => (X => X2, Y => Y2),
          C => (X => X3, Y => Y3)));
   end Paint_Filled_Triangle;

   procedure Paint_Filled_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle)
   is
      procedure Fill_Row
        (X_Start : Glyph.Types.Coordinate;
         X_End   : Glyph.Types.Coordinate;
         Y       : Glyph.Types.Coordinate) is
      begin
         if Y >= 0 and then Y <= Max_Y then
            for X in Coordinate'Max (0, X_Start) ..
                     Coordinate'Min (Max_X, X_End) loop
               Self.Buffer (Natural (X), Natural (Y)) := Glyph.Colors.On;
            end loop;
         end if;
      end Fill_Row;

      procedure Fill_Tri is new Glyph.Algorithms.Triangle.Rasterize_Filled_Triangle
        (Fill_Row => Fill_Row);

   begin
      Fill_Tri (Tri => Triangle, X_Max => Max_X, Y_Max => Max_Y);
   end Paint_Filled_Triangle;

   function Get_Pixel
     (Self : Instance;
      X    : Natural;
      Y    : Natural) return Glyph.Colors.Monochrome is
   begin
      return Self.Buffer (X, Y);
   end Get_Pixel;

   procedure Fill_Page_Stream
     (Self        : Instance;
      Data        : out Glyph.Transport.Byte_Array;
      Prefix_Byte : Glyph.Transport.Byte := 16#40#;
      Has_Prefix  : Boolean := True)
   is
      Pixel_Byte : Byte;
      Data_Index : Positive := Data'First;
      Pixel_Y    : Natural;
   begin
      if Has_Prefix then
         Data (Data_Index) := Prefix_Byte;
         Data_Index := Data_Index + 1;
      end if;

      for Page in 0 .. Total_Pages - 1 loop
         for X in 0 .. Width - 1 loop
            Pixel_Byte := 0;
            for Bit in 0 .. 7 loop
               Pixel_Y := Page * 8 + Bit;
               if Pixel_Y < Height then
                  if Self.Get_Pixel (X, Pixel_Y) = Glyph.Colors.On then
                     Pixel_Byte := Pixel_Byte or Byte (2 ** Bit);
                  end if;
               end if;
            end loop;

            if Data_Index <= Data'Last then
               Data (Data_Index) := Pixel_Byte;
               Data_Index := Data_Index + 1;
            end if;
         end loop;
      end loop;
   end Fill_Page_Stream;

end Glyph.Canvas.Generic_Mono;
