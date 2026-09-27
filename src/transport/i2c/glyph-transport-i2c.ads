with HAL.I2C;

package Glyph.Transport.I2C is

   procedure I2C_Write
     (Bus     : in out HAL.I2C.I2C_Port'Class;
      Address : HAL.I2C.I2C_Address;
      Data    : Byte_Array);

end Glyph.Transport.I2C;
