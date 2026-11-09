with Glyph.Algorithms.Clipping;
with Glyph.Algorithms.Lines;
with Glyph.Algorithms.Rectangle;
with Glyph.Algorithms.Circle;
with Glyph.Algorithms.Triangle;

package body Glyph.Canvas.Generic_RGB565 with
  SPARK_Mode => Off
is

   use Glyph.Transport;
   use Glyph.Types;

   Max_X : constant Glyph.Types.Coordinate :=
     Glyph.Types.Coordinate (Width - 1);
   Max_Y : constant Glyph.Types.Coordinate :=
     Glyph.Types.Coordinate (Height - 1);

   procedure Clear
     (Self : in out Instance;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.Black)
   is
   begin
      Self.Buffer := (others => (others => Color));
      Self.Mark_All_Dirty;
   end Clear;

   procedure Paint_Pixel
     (Self  : in out Instance;
      X     : Integer;
      Y     : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      if X >= 0 and then X <= Max_X and then Y >= 0 and then Y <= Max_Y then
         Self.Buffer (Natural (X), Natural (Y)) := Color;

         if not Self.Damage.Has_Damage then
            Self.Damage :=
              (Has_Damage => True,
               Min_X      => Natural (X),
               Max_X      => Natural (X),
               Min_Y      => Natural (Y),
               Max_Y      => Natural (Y));
         else
            Self.Damage.Min_X := Natural'Min (Self.Damage.Min_X, Natural (X));
            Self.Damage.Max_X := Natural'Max (Self.Damage.Max_X, Natural (X));
            Self.Damage.Min_Y := Natural'Min (Self.Damage.Min_Y, Natural (Y));
            Self.Damage.Max_Y := Natural'Max (Self.Damage.Max_Y, Natural (Y));
         end if;
      end if;
   end Paint_Pixel;

   procedure Paint_Line
     (Self  : in out Instance;
      X1    : Integer;
      Y1    : Integer;
      X2    : Integer;
      Y2    : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      Self.Paint_Line
        (Line  => ((Start_Point => (X => X1, Y => Y1), End_Point => (X => X2, Y => Y2))),
         Color => Color);
   end Paint_Line;

   procedure Paint_Line
     (Self  : in out Instance;
      Line  : Glyph.Types.Line;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
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
         Self.Paint_Pixel (Integer (X), Integer (Y), Color);
      end Plot;

      procedure Draw is new
        Glyph.Algorithms.Lines.Rasterize_Line (Plot => Plot);
   begin
      if Clip.Visible then
         Draw (Clip.Clipped);
      end if;
   end Paint_Line;

   procedure Paint_Rectangle
     (Self   : in out Instance;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      if Width > 0 and then Height > 0 then
         Self.Paint_Rectangle
           (Rect  =>
              (X      => X,
               Y      => Y,
               Width  => Natural (Width),
               Height => Natural (Height)),
            Color => Color);
      end if;
   end Paint_Rectangle;

   procedure Paint_Rectangle
     (Self  : in out Instance;
      Rect  : Glyph.Types.Rectangle;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
      procedure H_Span
        (X_Start : Glyph.Types.Coordinate;
         X_End   : Glyph.Types.Coordinate;
         Y       : Glyph.Types.Coordinate)
      is
      begin
         if Y >= 0 and then Y <= Max_Y then
            for X in Coordinate'Max (0, X_Start) .. Coordinate'Min (Max_X, X_End) loop
               Self.Paint_Pixel (Integer (X), Integer (Y), Color);
            end loop;
         end if;
      end H_Span;

      procedure V_Span
        (Y_Start : Glyph.Types.Coordinate;
         Y_End   : Glyph.Types.Coordinate;
         X       : Glyph.Types.Coordinate)
      is
      begin
         if X >= 0 and then X <= Max_X then
            for Y in Coordinate'Max (0, Y_Start) .. Coordinate'Min (Max_Y, Y_End) loop
               Self.Paint_Pixel (Integer (X), Integer (Y), Color);
            end loop;
         end if;
      end V_Span;

      procedure Draw_Outline is new
        Glyph.Algorithms.Rectangle.Rasterize_Rectangle
          (Plot_Horizontal_Span => H_Span,
           Plot_Vertical_Span   => V_Span);
   begin
      Draw_Outline (Rect => Rect, X_Max => Max_X, Y_Max => Max_Y);
   end Paint_Rectangle;

   procedure Paint_Filled_Rectangle
     (Self   : in out Instance;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      if Width > 0 and then Height > 0 then
         Self.Paint_Filled_Rectangle
           (Rect  =>
              (X      => X,
               Y      => Y,
               Width  => Natural (Width),
               Height => Natural (Height)),
            Color => Color);
      end if;
   end Paint_Filled_Rectangle;

   procedure Paint_Filled_Rectangle
     (Self  : in out Instance;
      Rect  : Glyph.Types.Rectangle;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
      procedure Fill_Row
        (X_Start : Glyph.Types.Coordinate;
         X_End   : Glyph.Types.Coordinate;
         Y       : Glyph.Types.Coordinate)
      is
      begin
         if Y >= 0 and then Y <= Max_Y then
            for X in Coordinate'Max (0, X_Start) .. Coordinate'Min (Max_X, X_End) loop
               Self.Paint_Pixel (Integer (X), Integer (Y), Color);
            end loop;
         end if;
      end Fill_Row;

      procedure Draw_Filled is new
        Glyph.Algorithms.Rectangle.Rasterize_Filled_Rectangle
          (Fill_Row => Fill_Row);
   begin
      Draw_Filled (Rect => Rect, X_Max => Max_X, Y_Max => Max_Y);
   end Paint_Filled_Rectangle;

   procedure Paint_Circle
     (Self        : in out Instance;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
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
            Self.Paint_Pixel (Integer (X), Integer (Y), Color);
         end Plot;

         procedure Draw_Circle is new
           Glyph.Algorithms.Circle.Rasterize_Circle (Plot => Plot);

         procedure Draw_Arc is new
           Glyph.Algorithms.Circle.Rasterize_Arc (Plot => Plot);
      begin
         if Sweep = 360 or else (Start_Angle = 0 and then End_Angle = 360) then
            Draw_Circle
              (Circle =>
                 (Center => (X => Center_X, Y => Center_Y),
                  Radius => Natural (Radius)),
               X_Max  => Max_X,
               Y_Max  => Max_Y);
         else
            Draw_Arc
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
     (Self  : in out Instance;
      Circle : Glyph.Types.Circle;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      Self.Paint_Circle
        (Center_X => Circle.Center.X,
         Center_Y => Circle.Center.Y,
         Radius   => Integer (Circle.Radius),
         Color    => Color);
   end Paint_Circle;

   procedure Paint_Filled_Circle
     (Self        : in out Instance;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
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
            Self.Paint_Pixel (Integer (X), Integer (Y), Color);
         end Plot;

         procedure Fill_Row
           (X_Start : Glyph.Types.Coordinate;
            X_End   : Glyph.Types.Coordinate;
            Y       : Glyph.Types.Coordinate)
         is
         begin
            if Y >= 0 and then Y <= Max_Y then
               for X in Coordinate'Max (0, X_Start) .. Coordinate'Min (Max_X, X_End) loop
                  Self.Paint_Pixel (Integer (X), Integer (Y), Color);
               end loop;
            end if;
         end Fill_Row;

         procedure Draw_Circle is new
           Glyph.Algorithms.Circle.Rasterize_Filled_Circle (Fill_Row => Fill_Row);

         procedure Draw_Sector is new
           Glyph.Algorithms.Circle.Rasterize_Filled_Sector
             (Plot     => Plot,
              Fill_Row => Fill_Row);
      begin
         if Sweep = 360 or else (Start_Angle = 0 and then End_Angle = 360) then
            Draw_Circle
              (Circle =>
                 (Center => (X => Center_X, Y => Center_Y),
                  Radius => Natural (Radius)),
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
      Circle : Glyph.Types.Circle;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      Self.Paint_Filled_Circle
        (Center_X => Circle.Center.X,
         Center_Y => Circle.Center.Y,
         Radius   => Integer (Circle.Radius),
         Color    => Color);
   end Paint_Filled_Circle;

   procedure Paint_Arc
     (Self        : in out Instance;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      Self.Paint_Circle
        (Center_X    => Center_X,
         Center_Y    => Center_Y,
         Radius      => Radius,
         Start_Angle => Start_Angle,
         End_Angle   => End_Angle,
         Color       => Color);
   end Paint_Arc;

   procedure Paint_Half_Circle
     (Self     : in out Instance;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer;
      Side     : Glyph.Types.Hemisphere := Glyph.Types.Top;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
      Start_Angle : Integer;
      End_Angle   : Integer;
   begin
      case Side is
         when Top    => Start_Angle := 180; End_Angle := 360;
         when Bottom => Start_Angle := 0;   End_Angle := 180;
         when Left   => Start_Angle := 90;  End_Angle := 270;
         when Right  => Start_Angle := 270; End_Angle := 90;
      end case;

      Self.Paint_Arc
        (Center_X    => Center_X,
         Center_Y    => Center_Y,
         Radius      => Radius,
         Start_Angle => Start_Angle,
         End_Angle   => End_Angle,
         Color       => Color);
   end Paint_Half_Circle;

   procedure Paint_Filled_Half_Circle
     (Self     : in out Instance;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer;
      Side     : Glyph.Types.Hemisphere := Glyph.Types.Top;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
      Start_Angle : Integer;
      End_Angle   : Integer;
   begin
      case Side is
         when Top    => Start_Angle := 180; End_Angle := 360;
         when Bottom => Start_Angle := 0;   End_Angle := 180;
         when Left   => Start_Angle := 90;  End_Angle := 270;
         when Right  => Start_Angle := 270; End_Angle := 90;
      end case;

      Self.Paint_Filled_Circle
        (Center_X    => Center_X,
         Center_Y    => Center_Y,
         Radius      => Radius,
         Start_Angle => Start_Angle,
         End_Angle   => End_Angle,
         Color       => Color);
   end Paint_Filled_Half_Circle;

   procedure Paint_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      Self.Paint_Triangle
        (Triangle =>
           (A => (X => X1, Y => Y1),
            B => (X => X2, Y => Y2),
            C => (X => X3, Y => Y3)),
         Color    => Color);
   end Paint_Triangle;

   procedure Paint_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
      procedure Draw_Line (Line : Glyph.Types.Line) is
      begin
         Self.Paint_Line (Line, Color);
      end Draw_Line;

      procedure Draw_Tri is new
        Glyph.Algorithms.Triangle.Rasterize_Triangle (Draw_Line => Draw_Line);
   begin
      Draw_Tri (Tri => Triangle);
   end Paint_Triangle;

   procedure Paint_Filled_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      Self.Paint_Filled_Triangle
        (Triangle =>
           (A => (X => X1, Y => Y1),
            B => (X => X2, Y => Y2),
            C => (X => X3, Y => Y3)),
         Color    => Color);
   end Paint_Filled_Triangle;

   procedure Paint_Filled_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
      procedure Fill_Row
        (X_Start : Glyph.Types.Coordinate;
         X_End   : Glyph.Types.Coordinate;
         Y       : Glyph.Types.Coordinate)
      is
      begin
         if Y >= 0 and then Y <= Max_Y then
            for X in Coordinate'Max (0, X_Start) .. Coordinate'Min (Max_X, X_End) loop
               Self.Paint_Pixel (Integer (X), Integer (Y), Color);
            end loop;
         end if;
      end Fill_Row;

      procedure Draw_Filled_Tri is new
        Glyph.Algorithms.Triangle.Rasterize_Filled_Triangle (Fill_Row => Fill_Row);
   begin
      Draw_Filled_Tri (Tri => Triangle, X_Max => Max_X, Y_Max => Max_Y);
   end Paint_Filled_Triangle;

   procedure Set_Default_Font (Self : in out Instance; F : Glyph.Fonts.Font) is
   begin
      Self.Default_Font := F;
   end Set_Default_Font;

   function Get_Default_Font (Self : Instance) return Glyph.Fonts.Font is
   begin
      return Self.Default_Font;
   end Get_Default_Font;

   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Text     : String;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False)
   is
   begin
      Self.Paint_Text
        (X        => X,
         Y        => Y,
         Text     => Text,
         Font     => Self.Default_Font,
         Scale    => Scale,
         Color    => Color,
         Bg_Color => Bg_Color,
         Opaque   => Opaque);
   end Paint_Text;

   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Char     : Character;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False)
   is
   begin
      Self.Paint_Text
        (X        => X,
         Y        => Y,
         Char     => Char,
         Font     => Self.Default_Font,
         Scale    => Scale,
         Color    => Color,
         Bg_Color => Bg_Color,
         Opaque   => Opaque);
   end Paint_Text;

   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Char     : Character;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False)
   is
      Index      : Positive;
      Byte_Val   : Glyph.Transport.Byte;
      Pixel_On   : Boolean;
   begin
      if Char < Font.First_Char or else Char > Font.Last_Char then
         return;
      end if;

      Index := (Character'Pos (Char) - Character'Pos (Font.First_Char)) * Font.Width + 1;

      for Col in 0 .. Font.Width - 1 loop
         Byte_Val := Font.Data (Index + Col);

         for Row in 0 .. Font.Height - 1 loop
            Pixel_On := (Byte_Val and (2 ** Row)) /= 0;

            if Pixel_On then
               if Scale = 1 then
                  Self.Paint_Pixel (X + Col, Y + Row, Color);
               else
                  for SX in 0 .. Scale - 1 loop
                     for SY in 0 .. Scale - 1 loop
                        Self.Paint_Pixel
                          (X + Col * Scale + SX,
                           Y + Row * Scale + SY,
                           Color);
                     end loop;
                  end loop;
               end if;
            elsif Opaque then
               if Scale = 1 then
                  Self.Paint_Pixel (X + Col, Y + Row, Bg_Color);
               else
                  for SX in 0 .. Scale - 1 loop
                     for SY in 0 .. Scale - 1 loop
                        Self.Paint_Pixel
                          (X + Col * Scale + SX,
                           Y + Row * Scale + SY,
                           Bg_Color);
                     end loop;
                  end loop;
               end if;
            end if;
         end loop;
      end loop;

      if Opaque then
         for Row in 0 .. Font.Height - 1 loop
            if Scale = 1 then
               Self.Paint_Pixel (X + Font.Width, Y + Row, Bg_Color);
            else
               for SX in 0 .. Scale - 1 loop
                  for SY in 0 .. Scale - 1 loop
                     Self.Paint_Pixel
                       (X + Font.Width * Scale + SX,
                        Y + Row * Scale + SY,
                        Bg_Color);
                  end loop;
               end loop;
            end if;
         end loop;
      end if;
   end Paint_Text;

   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Text     : String;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False)
   is
      Cur_X     : Integer := X;
      Cur_Y     : Integer := Y;
      Char_Step : constant Integer := (Font.Width + 1) * Scale;
      Line_Step : constant Integer := (Font.Height + 1) * Scale;
   begin
      for Char of Text loop
         if Char = ASCII.LF then
            Cur_X := X;
            Cur_Y := Cur_Y + Line_Step;
         elsif Char = ASCII.CR then
            Cur_X := X;
         else
            Self.Paint_Text
              (X        => Cur_X,
               Y        => Cur_Y,
               Char     => Char,
               Font     => Font,
               Scale    => Scale,
               Color    => Color,
               Bg_Color => Bg_Color,
               Opaque   => Opaque);
            Cur_X := Cur_X + Char_Step;
         end if;
      end loop;
   end Paint_Text;

   function Has_Damage (Self : Instance) return Boolean is
   begin
      return Self.Damage.Has_Damage;
   end Has_Damage;

   function Get_Damage (Self : Instance) return Glyph.Types.Rectangle is
   begin
      return
        (X      => Integer (Self.Damage.Min_X),
         Y      => Integer (Self.Damage.Min_Y),
         Width  => Natural (Self.Damage.Max_X - Self.Damage.Min_X + 1),
         Height => Natural (Self.Damage.Max_Y - Self.Damage.Min_Y + 1));
   end Get_Damage;

   procedure Reset_Damage (Self : in out Instance) is
   begin
      Self.Damage := (Has_Damage => False, others => 0);
   end Reset_Damage;

   procedure Mark_Dirty (Self : in out Instance; Rect : Glyph.Types.Rectangle) is
      R_Min_X : constant Natural :=
        Natural'Min (Width - 1, Natural'Max (0, Rect.X));
      R_Max_X : constant Natural :=
        Natural'Min (Width - 1, Natural'Max (0, Rect.X + Integer (Rect.Width) - 1));
      R_Min_Y : constant Natural :=
        Natural'Min (Height - 1, Natural'Max (0, Rect.Y));
      R_Max_Y : constant Natural :=
        Natural'Min (Height - 1, Natural'Max (0, Rect.Y + Integer (Rect.Height) - 1));
   begin
      if Rect.Width = 0 or else Rect.Height = 0 then
         return;
      end if;

      if not Self.Damage.Has_Damage then
         Self.Damage :=
           (Has_Damage => True,
            Min_X      => R_Min_X,
            Max_X      => R_Max_X,
            Min_Y      => R_Min_Y,
            Max_Y      => R_Max_Y);
      else
         Self.Damage.Min_X := Natural'Min (Self.Damage.Min_X, R_Min_X);
         Self.Damage.Max_X := Natural'Max (Self.Damage.Max_X, R_Max_X);
         Self.Damage.Min_Y := Natural'Min (Self.Damage.Min_Y, R_Min_Y);
         Self.Damage.Max_Y := Natural'Max (Self.Damage.Max_Y, R_Max_Y);
      end if;
   end Mark_Dirty;

   procedure Mark_All_Dirty (Self : in out Instance) is
   begin
      Self.Damage :=
        (Has_Damage => True,
         Min_X      => 0,
         Max_X      => Width - 1,
         Min_Y      => 0,
         Max_Y      => Height - 1);
   end Mark_All_Dirty;

   function Get_Pixel
     (Self : Instance; X : Natural; Y : Natural) return Glyph.Colors.RGB565 is
   begin
      return Self.Buffer (X, Y);
   end Get_Pixel;

   procedure Export_Window_Stream
     (Self      : Instance;
      Col_Start : X_Range;
      Col_End   : X_Range;
      Row_Start : Y_Range;
      Row_End   : Y_Range;
      Data      : out Glyph.Transport.Byte_Array)
   is
      Offset : Positive := Data'First;
      Pix    : Glyph.Colors.RGB565;
   begin
      for Y in Row_Start .. Row_End loop
         for X in Col_Start .. Col_End loop
            Pix := Self.Buffer (X, Y);
            Data (Offset)     := Byte (Natural (Pix) / 256);
            Data (Offset + 1) := Byte (Natural (Pix) mod 256);
            Offset := Offset + 2;
         end loop;
      end loop;
   end Export_Window_Stream;

end Glyph.Canvas.Generic_RGB565;
