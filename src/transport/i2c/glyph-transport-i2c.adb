with HAL;

package body Glyph.Transport.I2C is

   HAL_Buffer : HAL.I2C.I2C_Data (1 .. 1025);

   procedure I2C_Write
     (Bus     : in out HAL.I2C.I2C_Port'Class;
      Address : HAL.I2C.I2C_Address;
      Data    : Byte_Array)
   is
      Status : HAL.I2C.I2C_Status;
   begin
      if Data'Length <= HAL_Buffer'Length then
         for Index in Data'Range loop
            HAL_Buffer (Index - Data'First + 1) := HAL.UInt8 (Data (Index));
         end loop;

         Bus.Master_Transmit
           (Addr   => HAL.I2C.I2C_Address (Natural (Address) * 2),
            Data   => HAL_Buffer (1 .. Data'Length),
            Status => Status);
      end if;
   end I2C_Write;

end Glyph.Transport.I2C;
