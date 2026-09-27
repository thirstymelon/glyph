with HAL.I2C;
with Glyph.Transport;

package Glyph.Controllers.SSD1306 is

   Default_I2C_Address : constant HAL.I2C.I2C_Address := 16#3C#;

   type Controller (Address : HAL.I2C.I2C_Address := Default_I2C_Address) is
     tagged limited record
      Initialized : Boolean := False;
   end record;

   procedure Initialize
     (Self : in out Controller; Bus : in out HAL.I2C.I2C_Port'Class);

   procedure Flush
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class;
      Data : Glyph.Transport.Byte_Array);

end Glyph.Controllers.SSD1306;
