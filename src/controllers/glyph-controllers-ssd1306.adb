with Glyph.Transport.I2C;

package body Glyph.Controllers.SSD1306 is

   use Glyph.Transport;

   procedure Command
     (Bus     : in out HAL.I2C.I2C_Port'Class;
      Address : HAL.I2C.I2C_Address;
      Value   : Byte) is
   begin
      Glyph.Transport.I2C.I2C_Write
        (Bus => Bus, Address => Address, Data => (1 => 16#00#, 2 => Value));
   end Command;

   procedure Initialize
     (Self : in out Controller; Bus : in out HAL.I2C.I2C_Port'Class) is
   begin
      --  Turn display panel off (sleep mode)
      Command (Bus, Self.Address, 16#AE#);

      --  Set display clock divide ratio and internal oscillator frequency
      Command (Bus, Self.Address, 16#D5#);
      Command (Bus, Self.Address, 16#80#);

      --  Set multiplex ratio for 128x64 display (64 lines)
      Command (Bus, Self.Address, 16#A8#);
      Command (Bus, Self.Address, 16#3F#);

      --  Set display offset (no vertical display shift)
      Command (Bus, Self.Address, 16#D3#);
      Command (Bus, Self.Address, 16#00#);

      --  Set display RAM start line to 0
      Command (Bus, Self.Address, 16#40#);

      --  Enable internal charge pump regulator (7.5V generated internally)
      Command (Bus, Self.Address, 16#8D#);
      Command (Bus, Self.Address, 16#14#);

      --  Set memory addressing mode to horizontal addressing mode
      Command (Bus, Self.Address, 16#20#);
      Command (Bus, Self.Address, 16#00#);

      --  Set segment re-map: column address 127 mapped to SEG0
      Command (Bus, Self.Address, 16#A1#);

      --  Set COM output scan direction: remapped mode (COM63 down to COM0)
      Command (Bus, Self.Address, 16#C8#);

      --  Set COM pins hardware configuration for alternative COM pin layout
      Command (Bus, Self.Address, 16#DA#);
      Command (Bus, Self.Address, 16#12#);

      --  Set contrast control register (brightness)
      Command (Bus, Self.Address, 16#81#);
      Command (Bus, Self.Address, 16#CF#);

      --  Set pre-charge period (phase 1: 1 DCLK, phase 2: 15 DCLK)
      Command (Bus, Self.Address, 16#D9#);
      Command (Bus, Self.Address, 16#F1#);

      --  Set VCOMH regulator deselect level (~0.77 x Vcc)
      Command (Bus, Self.Address, 16#DB#);
      Command (Bus, Self.Address, 16#40#);

      --  Resume display from RAM content (normal GDDRAM output)
      Command (Bus, Self.Address, 16#A4#);

      --  Set normal display mode (uninverted: 1 = pixel on, 0 = pixel off)
      Command (Bus, Self.Address, 16#A6#);

      --  Turn display panel on
      Command (Bus, Self.Address, 16#AF#);

      Self.Initialized := True;
   end Initialize;

   procedure Flush
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class;
      Data : Glyph.Transport.Byte_Array) is
   begin
      if not Self.Initialized then
         raise Program_Error;
      end if;

      Command (Bus, Self.Address, 16#21#);
      Command (Bus, Self.Address, 16#00#);
      Command (Bus, Self.Address, 16#7F#);

      Command (Bus, Self.Address, 16#22#);
      Command (Bus, Self.Address, 16#00#);
      Command (Bus, Self.Address, 16#07#);

      Glyph.Transport.I2C.I2C_Write
        (Bus => Bus, Address => Self.Address, Data => Data);
   end Flush;

   procedure Set_Address_Window
     (Self       : in out Controller;
      Bus        : in out HAL.I2C.I2C_Port'Class;
      Col_Start  : Natural;
      Col_End    : Natural;
      Page_Start : Natural;
      Page_End   : Natural) is
   begin
      if not Self.Initialized then
         raise Program_Error;
      end if;

      Glyph.Transport.I2C.I2C_Write
        (Bus     => Bus,
         Address => Self.Address,
         Data    =>
           (1 => 16#00#,
            2 => 16#21#,
            3 => Byte (Col_Start),
            4 => Byte (Col_End),
            5 => 16#22#,
            6 => Byte (Page_Start),
            7 => Byte (Page_End)));
   end Set_Address_Window;

   procedure Write_Data
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class;
      Data : Glyph.Transport.Byte_Array) is
   begin
      if not Self.Initialized then
         raise Program_Error;
      end if;

      Glyph.Transport.I2C.I2C_Write
        (Bus => Bus, Address => Self.Address, Data => Data);
   end Write_Data;

end Glyph.Controllers.SSD1306;
