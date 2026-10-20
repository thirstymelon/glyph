with Glyph.Colors;

package body Glyph.Display is

   Transmit_Buffer : Glyph.Transport.Byte_Array (1 .. 1025);

   function Get_Display (Kind : Display_Type) return Display_T is
   begin
      case Kind is
         when SSD1306_128x64_I2C =>
            return
              (Canvas     =>
                 (Buffer => (others => (others => Glyph.Colors.Off))),
               Controller =>
                 (Address     => Glyph.Controllers.SSD1306.Default_I2C_Address,
                  Initialized => False),
               Bus        => null,
               Mode       => Framebuffer);
      end case;
   end Get_Display;

   procedure Set_Transport_Mode
     (Self : in out Display_T; Mode : Transport_Mode) is
   begin
      Self.Mode := Mode;
   end Set_Transport_Mode;

   function Get_Transport_Mode (Self : Display_T) return Transport_Mode is
   begin
      return Self.Mode;
   end Get_Transport_Mode;

   procedure Init
     (Self : in out Display_T; Bus : access HAL.I2C.I2C_Port'Class) is
   begin
      Self.Bus := Bus;
      if Bus /= null then
         Self.Controller.Initialize (Bus => Bus.all);
      end if;
   end Init;

   procedure Render (Self : in out Display_T) is
   begin
      if Self.Bus /= null then
         case Self.Mode is
            when Framebuffer   =>
               Self.Canvas.Fill_Page_Stream (Transmit_Buffer);
               Self.Controller.Flush
                 (Bus => Self.Bus.all, Data => Transmit_Buffer);

            when GDDRAM_Stream =>
               --  In direct GDDRAM stream mode, data is streamed directly to the
               --  display hardware without storing in a local MCU framebuffer.
               null;
         end case;
      end if;
   end Render;

   procedure Stream_Clear (Self : in out Display_T) is
      Zero_Chunk : constant Glyph.Transport.Byte_Array (1 .. 17) :=
        (1 => 16#40#, others => 0);
   begin
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
   end Stream_Clear;

   procedure Stream_Text
     (Self   : in out Display_T;
      Page   : Natural;
      Column : Natural;
      Text   : String;
      Font   : Glyph.Fonts.Font := Glyph.Fonts.Font_5x7)
   is
      Col_End     : Natural;
      Total_Cols  : constant Natural := Text'Length * (Font.Width + 1);
      Char_Buf    : Glyph.Transport.Byte_Array (1 .. Font.Width + 2);
      Actual_Char : Character;
      Char_Index  : Integer;
      Glyph_Start : Positive;
   begin
      if Self.Bus = null or else Page > 7 or else Column >= 128 then
         return;
      end if;

      Col_End := Natural'Min (127, Column + Total_Cols - 1);

      Self.Controller.Set_Address_Window
        (Bus        => Self.Bus.all,
         Col_Start  => Column,
         Col_End    => Col_End,
         Page_Start => Page,
         Page_End   => Page);

      for Char of Text loop
         Actual_Char := Char;
         if Actual_Char < Font.First_Char or else Actual_Char > Font.Last_Char
         then
            Actual_Char := '?';
         end if;

         Char_Index :=
           Character'Pos (Actual_Char) - Character'Pos (Font.First_Char);
         Glyph_Start := Font.Data'First + Char_Index * Font.Width;

         Char_Buf (1) := 16#40#;
         for C in 0 .. Font.Width - 1 loop
            Char_Buf (2 + C) := Font.Data (Glyph_Start + C);
         end loop;
         Char_Buf (Font.Width + 2) := 16#00#;

         Self.Controller.Write_Data (Bus => Self.Bus.all, Data => Char_Buf);
      end loop;
   end Stream_Text;

   procedure Stream_Data
     (Self       : in out Display_T;
      Col_Start  : Natural;
      Col_End    : Natural;
      Page_Start : Natural;
      Page_End   : Natural;
      Data       : Glyph.Transport.Byte_Array) is
   begin
      if Self.Bus /= null then
         Self.Controller.Set_Address_Window
           (Bus        => Self.Bus.all,
            Col_Start  => Col_Start,
            Col_End    => Col_End,
            Page_Start => Page_Start,
            Page_End   => Page_End);

         Self.Controller.Write_Data (Bus => Self.Bus.all, Data => Data);
      end if;
   end Stream_Data;

end Glyph.Display;
