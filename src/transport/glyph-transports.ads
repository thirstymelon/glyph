------------------------------------------------------------------------------
--  Glyph.Transports
--
--  Abstract transport interface for hardware I2C/SPI communication.
------------------------------------------------------------------------------

with Glyph.Types;

package Glyph.Transports is

   type Data_Kind is (Command, Pixel_Data);

   type Transport is limited interface;

   procedure Send
     (Self : in out Transport;
      Kind : Data_Kind;
      Data : Glyph.Types.Byte_Array) is abstract;

   procedure Reset (Self : in out Transport) is abstract;

end Glyph.Transports;
