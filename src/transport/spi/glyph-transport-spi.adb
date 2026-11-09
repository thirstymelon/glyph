with HAL;

package body Glyph.Transport.SPI with
  SPARK_Mode => Off
is

   use type HAL.UInt16;

   Chunk_Size : constant Positive := 512;
   Buffer     : HAL.SPI.SPI_Data_8b (1 .. Chunk_Size);

   procedure Write_Command
     (Port    : in out HAL.SPI.SPI_Port'Class;
      CS      : Any_GPIO_Point;
      DC      : in out HAL.GPIO.GPIO_Point'Class;
      Command : Glyph.Transport.Byte)
   is
      Status : HAL.SPI.SPI_Status;
      Cmd    : constant HAL.SPI.SPI_Data_8b (1 .. 1) :=
        [1 => HAL.UInt8 (Command)];
   begin
      if CS /= null then
         CS.Clear;
      end if;

      DC.Clear;  --  Low for Command

      Port.Transmit (Data => Cmd, Status => Status);

      if CS /= null then
         CS.Set;
      end if;
   end Write_Command;

   procedure Write_Data_Byte
     (Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Data : Glyph.Transport.Byte)
   is
      Status : HAL.SPI.SPI_Status;
      D      : constant HAL.SPI.SPI_Data_8b (1 .. 1) :=
        [1 => HAL.UInt8 (Data)];
   begin
      if CS /= null then
         CS.Clear;
      end if;

      DC.Set;  --  High for Data

      Port.Transmit (Data => D, Status => Status);

      if CS /= null then
         CS.Set;
      end if;
   end Write_Data_Byte;

   procedure Write_Data
     (Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Data : Glyph.Transport.Byte_Array)
   is
      Status    : HAL.SPI.SPI_Status;
      Remaining : Natural := Data'Length;
      Offset    : Positive := Data'First;
      To_Send   : Natural;
   begin
      if Remaining = 0 then
         return;
      end if;

      if CS /= null then
         CS.Clear;
      end if;

      DC.Set;  --  High for Data

      while Remaining > 0 loop
         To_Send := (if Remaining > Chunk_Size then Chunk_Size else Remaining);

         for I in 1 .. To_Send loop
            Buffer (I) := HAL.UInt8 (Data (Offset + I - 1));
         end loop;

         Port.Transmit (Data => Buffer (1 .. To_Send), Status => Status);

         Remaining := Remaining - To_Send;
         Offset    := Offset + To_Send;
      end loop;

      if CS /= null then
         CS.Set;
      end if;
   end Write_Data;

   procedure Write_Word16
     (Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Word : HAL.UInt16)
   is
      Status : HAL.SPI.SPI_Status;
      D      : constant HAL.SPI.SPI_Data_8b (1 .. 2) :=
        [1 => HAL.UInt8 (HAL.Shift_Right (Word, 8) and 16#FF#),
         2 => HAL.UInt8 (Word and 16#FF#)];
   begin
      if CS /= null then
         CS.Clear;
      end if;

      DC.Set;

      Port.Transmit (Data => D, Status => Status);

      if CS /= null then
         CS.Set;
      end if;
   end Write_Word16;

   procedure Write_Repeated_Word16
     (Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      Word  : HAL.UInt16;
      Count : Positive)
   is
      Status       : HAL.SPI.SPI_Status;
      Hi           : constant HAL.UInt8 :=
        HAL.UInt8 (HAL.Shift_Right (Word, 8) and 16#FF#);
      Lo           : constant HAL.UInt8 := HAL.UInt8 (Word and 16#FF#);
      Words_Chunk  : constant Positive := Chunk_Size / 2;
      Total_Words  : Natural := Count;
      Words_ToSend : Natural;
      Bytes_ToSend : Natural;
   begin
      --  Pre-populate chunk buffer with the 16-bit word pattern
      for I in 1 .. Words_Chunk loop
         Buffer (2 * I - 1) := Hi;
         Buffer (2 * I)     := Lo;
      end loop;

      if CS /= null then
         CS.Clear;
      end if;

      DC.Set;

      while Total_Words > 0 loop
         Words_ToSend :=
           (if Total_Words > Words_Chunk then Words_Chunk else Total_Words);
         Bytes_ToSend := Words_ToSend * 2;

         Port.Transmit (Data => Buffer (1 .. Bytes_ToSend), Status => Status);

         Total_Words := Total_Words - Words_ToSend;
      end loop;

      if CS /= null then
         CS.Set;
      end if;
   end Write_Repeated_Word16;

end Glyph.Transport.SPI;
