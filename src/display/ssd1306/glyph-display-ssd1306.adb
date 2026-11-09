with Glyph.Transport;

package body Glyph.Display.SSD1306 with
  SPARK_Mode => Off
is

   function Create return Display_T is
   begin
      return Create (Framebuffer);
   end Create;

   function Create (Mode : Transport_Mode) return Display_T is
   begin
      return Display_T'
        (Mode         => Mode,
         Controller   =>
           (Address     => Glyph.Controllers.SSD1306.Default_I2C_Address,
            Initialized => False),
         Bus          => null,
         Default_Font => Glyph.Fonts.Font_5x7,
         Canvas       => <>);
   end Create;

   procedure Init
     (Self : in out Display_T; Bus : access HAL.I2C.I2C_Port'Class) is
   begin
      if Bus /= null then
         Self.Bus := Bus.all'Unchecked_Access;
         Self.Controller.Initialize (Bus => Bus.all);
      else
         Self.Bus := null;
      end if;
   end Init;

   procedure Set_Address
     (Self : in out Display_T; Address : HAL.I2C.I2C_Address) is
   begin
      Self.Controller.Set_Address (Address);
   end Set_Address;

   function Get_Address (Self : Display_T) return HAL.I2C.I2C_Address is
   begin
      return Self.Controller.Get_Address;
   end Get_Address;

   procedure Set_Default_Font (Self : in out Display_T; F : Glyph.Fonts.Font) is
   begin
      Self.Default_Font := F;
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Set_Default_Font (F);
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
      if Self.Bus = null then
         return;
      end if;

      case Self.Mode is
         when Framebuffer =>
            if not Force and then not Self.Canvas.Has_Damage then
               return;
            end if;

            declare
               Stream_Buf : Glyph.Transport.Byte_Array (1 .. 1 + 1024);
            begin
               Self.Canvas.Fill_Page_Stream (Stream_Buf);
               Self.Controller.Flush
                 (Bus  => Self.Bus.all,
                  Data => Stream_Buf);
            end;

            Self.Canvas.Reset_Damage;

         when Direct_Stream =>
            null;
      end case;
   end Render;

   procedure Clear (Self : in out Display_T) is
      Zero_Chunk : constant Glyph.Transport.Byte_Array (1 .. 17) :=
        (1 => 16#40#, others => 0);
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Clear;
         when Direct_Stream =>
            if Self.Bus /= null then
               Self.Controller.Set_Address_Window
                 (Bus        => Self.Bus.all,
                  Col_Start  => 0,
                  Col_End    => 127,
                  Page_Start => 0,
                  Page_End   => 7);
               for Chunk in 1 .. 64 loop
                  Self.Controller.Write_Data
                    (Bus => Self.Bus.all, Data => Zero_Chunk);
               end loop;
            end if;
      end case;
   end Clear;

   procedure Paint_Pixel
     (Self  : in out Display_T;
      X     : Integer;
      Y     : Integer;
      Color : Glyph.Colors.Monochrome := Glyph.Colors.On) is
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Paint_Pixel (X, Y, Color);
         when Direct_Stream =>
            null;
      end case;
   end Paint_Pixel;

   procedure Paint_Line
     (Self   : in out Display_T;
      X1, Y1 : Integer;
      X2, Y2 : Integer) is
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Paint_Line (X1, Y1, X2, Y2);
         when Direct_Stream =>
            null;
      end case;
   end Paint_Line;

   procedure Paint_Rectangle
     (Self   : in out Display_T;
      X, Y   : Integer;
      Width  : Integer;
      Height : Integer) is
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Paint_Rectangle (X, Y, Width, Height);
         when Direct_Stream =>
            null;
      end case;
   end Paint_Rectangle;

   procedure Paint_Filled_Rectangle
     (Self   : in out Display_T;
      X, Y   : Integer;
      Width  : Integer;
      Height : Integer) is
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Paint_Filled_Rectangle (X, Y, Width, Height);
         when Direct_Stream =>
            null;
      end case;
   end Paint_Filled_Rectangle;

   procedure Paint_Circle
     (Self     : in out Display_T;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer) is
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Paint_Circle (Center_X, Center_Y, Radius);
         when Direct_Stream =>
            null;
      end case;
   end Paint_Circle;

   procedure Paint_Filled_Circle
     (Self     : in out Display_T;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer) is
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Paint_Filled_Circle (Center_X, Center_Y, Radius);
         when Direct_Stream =>
            null;
      end case;
   end Paint_Filled_Circle;

   procedure Paint_Text
     (Self     : in out Display_T;
      X, Y     : Integer;
      Text     : String;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False) is
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
      X, Y     : Integer;
      Text     : String;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False)
   is
   begin
      case Self.Mode is
         when Framebuffer =>
            Self.Canvas.Paint_Text
              (X        => X,
               Y        => Y,
               Text     => Text,
               Font     => Font,
               Scale    => Scale,
               Color    => Color,
               Bg_Color => Bg_Color,
               Opaque   => Opaque);
         when Direct_Stream =>
            if Self.Bus = null or else Y < 0 or else X < 0 then
               return;
            end if;

            declare
               Page        : constant Natural := Natural (Y / 8);
               Col_End     : Natural;
               Total_Cols  : constant Natural := Text'Length * (Font.Width + 1);
               Stream_Buf  : Glyph.Transport.Byte_Array (1 .. 129);
               Buf_Len     : Positive := 1;
               Actual_Char : Character;
               Char_Index  : Integer;
               Glyph_Start : Positive;
            begin
               if Page > 7 or else X >= 128 then
                  return;
               end if;

               Col_End := Natural'Min (127, X + Total_Cols - 1);
               Self.Controller.Set_Address_Window
                 (Bus        => Self.Bus.all,
                  Col_Start  => X,
                  Col_End    => Col_End,
                  Page_Start => Page,
                  Page_End   => Page);

               Stream_Buf (1) := 16#40#;
               for Char of Text loop
                  Actual_Char := Char;
                  if Actual_Char < Font.First_Char or else Actual_Char > Font.Last_Char then
                     Actual_Char := '?';
                  end if;

                  Char_Index :=
                    Character'Pos (Actual_Char) - Character'Pos (Font.First_Char);
                  Glyph_Start := Font.Data'First + Char_Index * Font.Width;

                  for C in 0 .. Font.Width - 1 loop
                     exit when Buf_Len >= Stream_Buf'Last;
                     Buf_Len := Buf_Len + 1;
                     Stream_Buf (Buf_Len) := Font.Data (Glyph_Start + C);
                  end loop;

                  if Buf_Len < Stream_Buf'Last then
                     Buf_Len := Buf_Len + 1;
                     Stream_Buf (Buf_Len) := 16#00#;
                  end if;
               end loop;

               if Buf_Len > 1 then
                  Self.Controller.Write_Data
                    (Bus  => Self.Bus.all,
                     Data => Stream_Buf (1 .. Buf_Len));
               end if;
            end;
      end case;
   end Paint_Text;

   procedure Paint_Text
     (Self     : in out Display_T;
      X, Y     : Integer;
      Char     : Character;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
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
      X, Y     : Integer;
      Char     : Character;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
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

end Glyph.Display.SSD1306;
