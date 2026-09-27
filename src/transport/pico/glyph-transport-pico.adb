with Glyph.Transport.I2C;

package body Glyph.Transport.Pico is

   procedure I2C_Write
     (Bus     : in out HAL.I2C.I2C_Port'Class;
      Address : Natural;
      Data    : Glyph.Transport.Byte_Array) is
   begin
      Glyph.Transport.I2C.I2C_Write
        (Bus     => Bus,
         Address => HAL.I2C.I2C_Address (Address),
         Data    => Data);
   end I2C_Write;

end Glyph.Transport.Pico;
