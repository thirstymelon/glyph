with Glyph.Algorithms.Lines;
with Glyph.Algorithms.Circle;
with Glyph.Algorithms.Triangle;
with Glyph.Types;

package body Glyph.Display.ILI9341 with
  SPARK_Mode => Off
is

   use Glyph.Transport;
   use type Glyph.Transport.SPI.Any_GPIO_Point;

   function Create return Display_T is
   begin
      return Create (Direct_Stream);
   end Create;

   function Create (Mode : Transport_Mode) return Display_T is
   begin
      return Display_T'
        (Mode          => Mode,
         Controller    => <>,
         SPI           => null,
         CS            => null,
         DC            => null,
         Reset         => null,
         Default_Font  => Glyph.Fonts.Font_5x7,
         Band_Offset_Y => 0,
         Tile_Canvas   => <>);
   end Create;

   procedure Init
     (Self  : in out Display_T;
      SPI   : access HAL.SPI.SPI_Port'Class;
      DC    : access HAL.GPIO.GPIO_Point'Class;
      CS    : access HAL.GPIO.GPIO_Point'Class := null;
      Reset : access HAL.GPIO.GPIO_Point'Class := null)
   is
   begin
      if SPI /= null then
         Self.SPI := SPI.all'Unchecked_Access;
      end if;
      if DC /= null then
         Self.DC := DC.all'Unchecked_Access;
      end if;
      if CS /= null then
         Self.CS := CS.all'Unchecked_Access;
      end if;
      if Reset /= null then
         Self.Reset := Reset.all'Unchecked_Access;
      end if;

      if Self.SPI /= null and then Self.DC /= null then
         Self.Controller.Initialize
           (Port  => Self.SPI.all,
            CS    => Self.CS,
            DC    => Self.DC.all,
            Reset => Self.Reset);
      end if;
   end Init;

   procedure Set_Orientation
     (Self        : in out Display_T;
      Orientation : Glyph.Controllers.ILI9341.Orientation_Type)
   is
   begin
      if Self.SPI /= null and then Self.DC /= null then
         Self.Controller.Set_Orientation
           (Port        => Self.SPI.all,
            CS          => Self.CS,
            DC          => Self.DC.all,
            Orientation => Orientation);
      end if;
   end Set_Orientation;

   procedure Set_Default_Font (Self : in out Display_T; F : Glyph.Fonts.Font) is
   begin
      Self.Default_Font := F;
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Set_Default_Font (F);
         when Direct_Stream =>
            null;
      end case;
   end Set_Default_Font;

   function Get_Default_Font (Self : Display_T) return Glyph.Fonts.Font is
   begin
      return Self.Default_Font;
   end Get_Default_Font;

   procedure Render (Self : in out Display_T; Force : Boolean := False) is
   begin
      if Self.SPI = null or else Self.DC = null then
         return;
      end if;

      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            declare
               Cols_Count  : constant Positive := 240;
               Row_Data    : Glyph.Transport.Byte_Array (1 .. Cols_Count * 2);
               Offset      : Positive;
               Pix         : Glyph.Colors.RGB565;
               Y_Abs_Start : constant Natural := Self.Band_Offset_Y;
               Y_Abs_End   : constant Natural := Self.Band_Offset_Y + 31;
            begin
               Self.Controller.Set_Address_Window
                 (Port    => Self.SPI.all,
                  CS      => Self.CS,
                  DC      => Self.DC.all,
                  X_Start => 0,
                  Y_Start => Y_Abs_Start,
                  X_End   => 239,
                  Y_End   => Y_Abs_End);

               for Y in 0 .. 31 loop
                  Offset := Row_Data'First;
                  for X in 0 .. 239 loop
                     Pix := Self.Tile_Canvas.Get_Pixel (X, Y);
                     Row_Data (Offset)     := Byte (Natural (Pix) / 256);
                     Row_Data (Offset + 1) := Byte (Natural (Pix) mod 256);
                     Offset := Offset + 2;
                  end loop;

                  Self.Controller.Write_Pixels
                    (Port => Self.SPI.all,
                     CS   => Self.CS,
                     DC   => Self.DC.all,
                     Data => Row_Data);
               end loop;
            end;

         when Direct_Stream =>
            null;
      end case;
   end Render;

   procedure Render_Scene
     (Self : in out Display_T;
      Draw : not null access procedure (Disp : in out Display_T))
   is
   begin
      case Self.Mode is
         when Framebuffer =>
            Draw (Self);
            Self.Render;
         when Direct_Stream =>
            Draw (Self);
         when Tile_Stream =>
            declare
               Stream_Buf : Glyph.Transport.Byte_Array (1 .. 240 * 32 * 2);
            begin
               for Band in 0 .. 9 loop
                  declare
                     Band_Y : constant Natural := Band * 32;
                  begin
                     Self.Band_Offset_Y := Band_Y;
                     Self.Tile_Canvas.Clear (Glyph.Colors.Black);
                     Draw (Self);
                     Self.Tile_Canvas.Export_Window_Stream
                       (Col_Start => 0,
                        Col_End   => 239,
                        Row_Start => 0,
                        Row_End   => 31,
                        Data      => Stream_Buf);

                     if Self.SPI /= null and then Self.DC /= null then
                        Self.Controller.Set_Address_Window
                          (Port    => Self.SPI.all,
                           CS      => Self.CS,
                           DC      => Self.DC.all,
                           X_Start => 0,
                           Y_Start => Band_Y,
                           X_End   => 239,
                           Y_End   => Band_Y + 31);

                        Self.Controller.Write_Pixels
                          (Port => Self.SPI.all,
                           CS   => Self.CS,
                           DC   => Self.DC.all,
                           Data => Stream_Buf);
                     end if;
                  end;
               end loop;
               Self.Band_Offset_Y := 0;
            end;
      end case;
   end Render_Scene;

   procedure Render_Scene
     (Self : in out Display_T;
      Draw : not null access procedure (Disp : in out Display_T; Offset_Y : Integer))
   is
   begin
      case Self.Mode is
         when Framebuffer =>
            Draw (Self, 0);
            Self.Render;
         when Direct_Stream =>
            Draw (Self, 0);
         when Tile_Stream =>
            declare
               Stream_Buf : Glyph.Transport.Byte_Array (1 .. 240 * 32 * 2);
            begin
               for Band in 0 .. 9 loop
                  declare
                     Band_Y : constant Natural := Band * 32;
                  begin
                     Self.Band_Offset_Y := 0;
                     Self.Tile_Canvas.Clear (Glyph.Colors.Black);
                     Draw (Self, Band_Y);
                     Self.Tile_Canvas.Export_Window_Stream
                       (Col_Start => 0,
                        Col_End   => 239,
                        Row_Start => 0,
                        Row_End   => 31,
                        Data      => Stream_Buf);

                     if Self.SPI /= null and then Self.DC /= null then
                        Self.Controller.Set_Address_Window
                          (Port    => Self.SPI.all,
                           CS      => Self.CS,
                           DC      => Self.DC.all,
                           X_Start => 0,
                           Y_Start => Band_Y,
                           X_End   => 239,
                           Y_End   => Band_Y + 31);

                        Self.Controller.Write_Pixels
                          (Port => Self.SPI.all,
                           CS   => Self.CS,
                           DC   => Self.DC.all,
                           Data => Stream_Buf);
                     end if;
                  end;
               end loop;
            end;
      end case;
   end Render_Scene;

   procedure Generic_Render_Scene (Self : in out Display_T) is
   begin
      case Self.Mode is
         when Framebuffer =>
            Draw (Self);
            Self.Render;
         when Direct_Stream =>
            Draw (Self);
         when Tile_Stream =>
            declare
               Stream_Buf : Glyph.Transport.Byte_Array (1 .. 240 * 32 * 2);
            begin
               for Band in 0 .. 9 loop
                  declare
                     Band_Y : constant Natural := Band * 32;
                  begin
                     Self.Band_Offset_Y := Band_Y;
                     Self.Tile_Canvas.Clear (Glyph.Colors.Black);
                     Draw (Self);
                     Self.Tile_Canvas.Export_Window_Stream
                       (Col_Start => 0,
                        Col_End   => 239,
                        Row_Start => 0,
                        Row_End   => 31,
                        Data      => Stream_Buf);

                     if Self.SPI /= null and then Self.DC /= null then
                        Self.Controller.Set_Address_Window
                          (Port    => Self.SPI.all,
                           CS      => Self.CS,
                           DC      => Self.DC.all,
                           X_Start => 0,
                           Y_Start => Band_Y,
                           X_End   => 239,
                           Y_End   => Band_Y + 31);

                        Self.Controller.Write_Pixels
                          (Port => Self.SPI.all,
                           CS   => Self.CS,
                           DC   => Self.DC.all,
                           Data => Stream_Buf);
                     end if;
                  end;
               end loop;
            end;
      end case;
   end Generic_Render_Scene;

   procedure Clear
     (Self  : in out Display_T;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.Black)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Clear (Color);
         when Direct_Stream =>
            if Self.SPI /= null and then Self.DC /= null then
               Self.Controller.Fill_Rect
                 (Port  => Self.SPI.all,
                  CS    => Self.CS,
                  DC    => Self.DC.all,
                  X     => 0,
                  Y     => 0,
                  W     => Self.Controller.Current_Width,
                  H     => Self.Controller.Current_Height,
                  Color => Color);
            end if;
      end case;
   end Clear;

   procedure Paint_Pixel
     (Self  : in out Display_T;
      X     : Integer;
      Y     : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
      Pix_Data : Glyph.Transport.Byte_Array (1 .. 2);
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Pixel (X, Y - Self.Band_Offset_Y, Color);
         when Direct_Stream =>
            if Self.SPI /= null and then Self.DC /= null
              and then X >= 0 and then X < Self.Controller.Current_Width
              and then Y >= 0 and then Y < Self.Controller.Current_Height
            then
               Pix_Data (1) := Byte (Natural (Color) / 256);
               Pix_Data (2) := Byte (Natural (Color) mod 256);
               Self.Controller.Set_Address_Window
                 (Port    => Self.SPI.all,
                  CS      => Self.CS,
                  DC      => Self.DC.all,
                  X_Start => X,
                  Y_Start => Y,
                  X_End   => X,
                  Y_End   => Y);
               Self.Controller.Write_Pixels
                 (Port => Self.SPI.all,
                  CS   => Self.CS,
                  DC   => Self.DC.all,
                  Data => Pix_Data);
            end if;
      end case;
   end Paint_Pixel;

   procedure Paint_Line
     (Self  : in out Display_T;
      X1    : Integer;
      Y1    : Integer;
      X2    : Integer;
      Y2    : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Line
              (X1, Y1 - Self.Band_Offset_Y, X2, Y2 - Self.Band_Offset_Y, Color);
         when Direct_Stream =>
            if Y1 = Y2 and then X1 <= X2 then
               Self.Paint_Filled_Rectangle (X1, Y1, X2 - X1 + 1, 1, Color);
            elsif X1 = X2 and then Y1 <= Y2 then
               Self.Paint_Filled_Rectangle (X1, Y1, 1, Y2 - Y1 + 1, Color);
            else
               declare
                  procedure Direct_Plot (X, Y : Glyph.Types.Coordinate) is
                  begin
                     Self.Paint_Pixel (Integer (X), Integer (Y), Color);
                  end Direct_Plot;

                  procedure Draw_L is new
                    Glyph.Algorithms.Lines.Rasterize_Line (Plot => Direct_Plot);
               begin
                  Draw_L
                    (Line =>
                       (Start_Point => (X => X1, Y => Y1),
                        End_Point   => (X => X2, Y => Y2)));
               end;
            end if;
      end case;
   end Paint_Line;

   procedure Paint_Rectangle
     (Self   : in out Display_T;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Rectangle
              (X, Y - Self.Band_Offset_Y, Width, Height, Color);
         when Direct_Stream =>
            if Width > 0 and then Height > 0 then
               Self.Paint_Filled_Rectangle (X, Y, Width, 1, Color);
               Self.Paint_Filled_Rectangle (X, Y + Height - 1, Width, 1, Color);
               Self.Paint_Filled_Rectangle (X, Y, 1, Height, Color);
               Self.Paint_Filled_Rectangle (X + Width - 1, Y, 1, Height, Color);
            end if;
      end case;
   end Paint_Rectangle;

   procedure Paint_Filled_Rectangle
     (Self   : in out Display_T;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Filled_Rectangle
              (X, Y - Self.Band_Offset_Y, Width, Height, Color);
         when Direct_Stream =>
            if Width <= 0 or else Height <= 0 or else Self.SPI = null or else Self.DC = null then
               return;
            end if;

            declare
               X1 : constant Integer := X;
               Y1 : constant Integer := Y;
               X2 : constant Integer := X + Width - 1;
               Y2 : constant Integer := Y + Height - 1;
               Max_X : constant Integer := Self.Controller.Current_Width - 1;
               Max_Y : constant Integer := Self.Controller.Current_Height - 1;
               Cl_X1, Cl_X2, Cl_Y1, Cl_Y2 : Integer;
            begin
               if X2 < 0 or else X1 > Max_X or else Y2 < 0 or else Y1 > Max_Y then
                  return;
               end if;

               Cl_X1 := Integer'Max (0, X1);
               Cl_X2 := Integer'Min (Max_X, X2);
               Cl_Y1 := Integer'Max (0, Y1);
               Cl_Y2 := Integer'Min (Max_Y, Y2);

               Self.Controller.Fill_Rect
                 (Port  => Self.SPI.all,
                  CS    => Self.CS,
                  DC    => Self.DC.all,
                  X     => Cl_X1,
                  Y     => Cl_Y1,
                  W     => Cl_X2 - Cl_X1 + 1,
                  H     => Cl_Y2 - Cl_Y1 + 1,
                  Color => Color);
            end;
      end case;
   end Paint_Filled_Rectangle;

   procedure Paint_Circle
     (Self        : in out Display_T;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Circle
              (Center_X, Center_Y - Self.Band_Offset_Y, Radius, Start_Angle, End_Angle, Color);
         when Direct_Stream =>
            declare
               procedure Direct_Plot (X, Y : Glyph.Types.Coordinate) is
               begin
                  Self.Paint_Pixel (Integer (X), Integer (Y), Color);
               end Direct_Plot;

               procedure Draw_C is new
                 Glyph.Algorithms.Circle.Rasterize_Circle (Plot => Direct_Plot);
            begin
               Draw_C
                 (Circle =>
                    (Center => (X => Center_X, Y => Center_Y),
                     Radius => Natural (Radius)),
                  X_Max  => Glyph.Types.Coordinate (Self.Controller.Current_Width - 1),
                  Y_Max  => Glyph.Types.Coordinate (Self.Controller.Current_Height - 1));
            end;
      end case;
   end Paint_Circle;

   procedure Paint_Filled_Circle
     (Self        : in out Display_T;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Filled_Circle
              (Center_X, Center_Y - Self.Band_Offset_Y, Radius, Start_Angle, End_Angle, Color);
         when Direct_Stream =>
            declare
               procedure Direct_Row
                 (X_Start, X_End, Y : Glyph.Types.Coordinate) is
               begin
                  if X_End >= X_Start then
                     Self.Paint_Filled_Rectangle
                       (Integer (X_Start),
                        Integer (Y),
                        Integer (X_End - X_Start + 1),
                        1,
                        Color);
                  end if;
               end Direct_Row;

               procedure Draw_FC is new
                 Glyph.Algorithms.Circle.Rasterize_Filled_Circle
                   (Fill_Row => Direct_Row);
            begin
               Draw_FC
                 (Circle =>
                    (Center => (X => Center_X, Y => Center_Y),
                     Radius => Natural (Radius)),
                  X_Max  => Glyph.Types.Coordinate (Self.Controller.Current_Width - 1),
                  Y_Max  => Glyph.Types.Coordinate (Self.Controller.Current_Height - 1));
            end;
      end case;
   end Paint_Filled_Circle;

   procedure Paint_Triangle
     (Self   : in out Display_T;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Triangle
              (X1, Y1 - Self.Band_Offset_Y,
               X2, Y2 - Self.Band_Offset_Y,
               X3, Y3 - Self.Band_Offset_Y,
               Color);
         when Direct_Stream =>
            Self.Paint_Line (X1, Y1, X2, Y2, Color);
            Self.Paint_Line (X2, Y2, X3, Y3, Color);
            Self.Paint_Line (X3, Y3, X1, Y1, Color);
      end case;
   end Paint_Triangle;

   procedure Paint_Filled_Triangle
     (Self   : in out Display_T;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Filled_Triangle
              (X1, Y1 - Self.Band_Offset_Y,
               X2, Y2 - Self.Band_Offset_Y,
               X3, Y3 - Self.Band_Offset_Y,
               Color);
         when Direct_Stream =>
            declare
               procedure Direct_Row
                 (X_Start, X_End, Y : Glyph.Types.Coordinate) is
               begin
                  if X_End >= X_Start then
                     Self.Paint_Filled_Rectangle
                       (Integer (X_Start),
                        Integer (Y),
                        Integer (X_End - X_Start + 1),
                        1,
                        Color);
                  end if;
               end Direct_Row;

               procedure Draw_FT is new
                 Glyph.Algorithms.Triangle.Rasterize_Filled_Triangle
                   (Fill_Row => Direct_Row);
            begin
               Draw_FT
                 (Tri   =>
                    (A => (X => X1, Y => Y1),
                     B => (X => X2, Y => Y2),
                     C => (X => X3, Y => Y3)),
                  X_Max => Glyph.Types.Coordinate (Self.Controller.Current_Width - 1),
                  Y_Max => Glyph.Types.Coordinate (Self.Controller.Current_Height - 1));
            end;
      end case;
   end Paint_Filled_Triangle;

   procedure Paint_Text
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
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
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
      Text     : String;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False)
   is
   begin
      case Self.Mode is
         when Framebuffer | Tile_Stream =>
            Self.Tile_Canvas.Paint_Text
              (X        => X,
               Y        => Y - Self.Band_Offset_Y,
               Text     => Text,
               Font     => Font,
               Scale    => Scale,
               Color    => Color,
               Bg_Color => Bg_Color,
               Opaque   => Opaque);
         when Direct_Stream =>
            declare
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
                     if Char >= Font.First_Char and then Char <= Font.Last_Char then
                        declare
                           Char_Idx  : constant Natural :=
                             Character'Pos (Char) - Character'Pos (Font.First_Char);
                           Glyph_Off : constant Positive :=
                             Font.Data'First + Char_Idx * Font.Width;
                           Col_Byte  : Glyph.Transport.Byte;
                           Pix_On    : Boolean;
                        begin
                           for Col in 0 .. Font.Width - 1 loop
                              Col_Byte := Font.Data (Glyph_Off + Col);
                              for Row in 0 .. Font.Height - 1 loop
                                 Pix_On := (Col_Byte and (2 ** Row)) /= 0;
                                 if Pix_On then
                                    if Scale = 1 then
                                       Self.Paint_Pixel
                                         (Cur_X + Col, Cur_Y + Row, Color);
                                    else
                                       Self.Paint_Filled_Rectangle
                                         (Cur_X + Col * Scale,
                                          Cur_Y + Row * Scale,
                                          Scale,
                                          Scale,
                                          Color);
                                    end if;
                                 elsif Opaque then
                                    if Scale = 1 then
                                       Self.Paint_Pixel
                                         (Cur_X + Col, Cur_Y + Row, Bg_Color);
                                    else
                                       Self.Paint_Filled_Rectangle
                                         (Cur_X + Col * Scale,
                                          Cur_Y + Row * Scale,
                                          Scale,
                                          Scale,
                                          Bg_Color);
                                    end if;
                                 end if;
                              end loop;
                           end loop;

                           if Opaque then
                              if Scale = 1 then
                                 for Row in 0 .. Font.Height - 1 loop
                                    Self.Paint_Pixel
                                      (Cur_X + Font.Width, Cur_Y + Row, Bg_Color);
                                 end loop;
                              else
                                 Self.Paint_Filled_Rectangle
                                   (Cur_X + Font.Width * Scale,
                                    Cur_Y,
                                    Scale,
                                    Font.Height * Scale,
                                    Bg_Color);
                              end if;
                           end if;
                        end;
                     end if;
                     Cur_X := Cur_X + Char_Step;
                  end if;
               end loop;
            end;
      end case;
   end Paint_Text;

   procedure Paint_Text
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
      Char     : Character;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False) is
   begin
      Self.Paint_Text
        (X        => X,
         Y        => Y,
         Text     => (1 => Char),
         Font     => Self.Default_Font,
         Scale    => Scale,
         Color    => Color,
         Bg_Color => Bg_Color,
         Opaque   => Opaque);
   end Paint_Text;

   procedure Paint_Text
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
      Char     : Character;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False) is
   begin
      Self.Paint_Text
        (X        => X,
         Y        => Y,
         Text     => (1 => Char),
         Font     => Font,
         Scale    => Scale,
         Color    => Color,
         Bg_Color => Bg_Color,
         Opaque   => Opaque);
   end Paint_Text;

end Glyph.Display.ILI9341;
