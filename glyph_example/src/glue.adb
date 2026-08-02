------------------------------------------------------------------------------
--  Glue - Binds Glyph and Pico_BSP
--
--  Implementation of I2C transport transmission using Pico_BSP HAL.I2C.
------------------------------------------------------------------------------

with HAL;
with Hal.I2C;
use type HAL.I2C.I2C_Status;

package body Glue is

   Send_Buffer_Size : constant := 64;

   overriding
   procedure Send
     (Self : in out Pico_I2C_Transport;
      Kind : Glyph.Transports.Data_Kind;
      Data : Glyph.Types.Byte_Array)
   is
      Status        : HAL.I2C.I2C_Status;
      Payload_Start : Positive := Data'First;
      Tx_Buffer     : HAL.I2C.I2C_Data (1 .. Send_Buffer_Size + 1);
   begin
      while Payload_Start <= Data'Last loop
         declare
            Payload_End : constant Positive :=
              Positive'Min (Payload_Start + Send_Buffer_Size - 1, Data'Last);
            Count       : constant Positive := Payload_End - Payload_Start + 1;
         begin
            Tx_Buffer (1) :=
              (case Kind is
                 when Glyph.Transports.Command    => 16#00#,
                 when Glyph.Transports.Pixel_Data => 16#40#);

            for I in 1 .. Count loop
               Tx_Buffer (1 + I) := HAL.UInt8 (Data (Payload_Start - 1 + I));
            end loop;

            Self.Port_Ptr.Master_Transmit
              (Addr   => Self.Device_Addr,
               Data   => Tx_Buffer (1 .. Count + 1),
               Status => Status);

            if Status /= HAL.I2C.Ok then
               raise Program_Error with "I2C transmit failed";
            end if;

            exit when Payload_End = Data'Last;
            Payload_Start := Payload_End + 1;
         end;
      end loop;
   end Send;

   overriding
   procedure Reset (Self : in out Pico_I2C_Transport) is
   begin
      null;
   end Reset;

end Glue;
