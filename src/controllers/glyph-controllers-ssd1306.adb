with Glyph.Transport.I2C;

package body Glyph.Controllers.SSD1306 is

   use Glyph.Transport;

   procedure Command
     (Bus     : in out HAL.I2C.I2C_Port'Class;
      Address : HAL.I2C.I2C_Address;
      Value   : Byte)
   is
   begin
      Glyph.Transport.I2C.I2C_Write
        (Bus     => Bus,
         Address => Address,
         Data    => (1 => 16#00#, 2 => Value));
   end Command;

   procedure Initialize
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class) is
   begin
      Command (Bus, Self.Address, 16#AE#);
      Command (Bus, Self.Address, 16#D5#); Command (Bus, Self.Address, 16#80#);
      Command (Bus, Self.Address, 16#A8#); Command (Bus, Self.Address, 16#3F#);
      Command (Bus, Self.Address, 16#D3#); Command (Bus, Self.Address, 16#00#);
      Command (Bus, Self.Address, 16#40#);
      Command (Bus, Self.Address, 16#8D#); Command (Bus, Self.Address, 16#14#);
      Command (Bus, Self.Address, 16#20#); Command (Bus, Self.Address, 16#00#);
      Command (Bus, Self.Address, 16#A1#);
      Command (Bus, Self.Address, 16#C8#);
      Command (Bus, Self.Address, 16#DA#); Command (Bus, Self.Address, 16#12#);
      Command (Bus, Self.Address, 16#81#); Command (Bus, Self.Address, 16#CF#);
      Command (Bus, Self.Address, 16#D9#); Command (Bus, Self.Address, 16#F1#);
      Command (Bus, Self.Address, 16#DB#); Command (Bus, Self.Address, 16#40#);
      Command (Bus, Self.Address, 16#A4#);
      Command (Bus, Self.Address, 16#A6#);
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
        (Bus     => Bus,
         Address => Self.Address,
         Data    => Data);
   end Flush;

end Glyph.Controllers.SSD1306;
