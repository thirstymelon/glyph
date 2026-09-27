with HAL.I2C;

package Glyph.Transport.Pico is

   procedure I2C_Write
     (Bus     : in out HAL.I2C.I2C_Port'Class;
      Address : Natural;
      Data    : Byte_Array);

end Glyph.Transport.Pico;
