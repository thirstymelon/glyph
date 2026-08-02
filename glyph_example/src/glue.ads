------------------------------------------------------------------------------
--  Glue - Binds Glyph and Pico_BSP
--
--  Glue package adapting Pico_BSP HAL.I2C to Glyph.Transports.Transport.
------------------------------------------------------------------------------

with HAL.I2C;
with RP.I2C_Master;
with Glyph.Transports;
with Glyph.Types;

package Glue is

   type Pico_I2C_Transport (Port_Ptr : access RP.I2C_Master.I2C_Master_Port) is
     new Glyph.Transports.Transport
   with record
      --  SSD1306 7-bit address 0x3C shifted left by 1 bit = 0x78
      Device_Addr : HAL.I2C.I2C_Address := 16#78#;
   end record;

   overriding
   procedure Send
     (Self : in out Pico_I2C_Transport;
      Kind : Glyph.Transports.Data_Kind;
      Data : Glyph.Types.Byte_Array);

   overriding
   procedure Reset (Self : in out Pico_I2C_Transport);

end Glue;
