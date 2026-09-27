with Glyph.Transport;
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
               Controller => (Address     => Glyph.Controllers.SSD1306.Default_I2C_Address,
                              Initialized => False),
               Bus        => null);
      end case;
   end Get_Display;

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
         Self.Canvas.Fill_Page_Stream (Transmit_Buffer);
         Self.Controller.Flush (Bus => Self.Bus.all, Data => Transmit_Buffer);
      end if;
   end Render;

end Glyph.Display;
