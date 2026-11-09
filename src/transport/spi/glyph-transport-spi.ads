with HAL.SPI;
with HAL.GPIO;

package Glyph.Transport.SPI with
  SPARK_Mode => Off
is

   type Any_GPIO_Point is access all HAL.GPIO.GPIO_Point'Class;

   procedure Write_Command
     (Port    : in out HAL.SPI.SPI_Port'Class;
      CS      : Any_GPIO_Point;
      DC      : in out HAL.GPIO.GPIO_Point'Class;
      Command : Glyph.Transport.Byte);

   procedure Write_Data_Byte
     (Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Data : Glyph.Transport.Byte);

   procedure Write_Data
     (Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Data : Glyph.Transport.Byte_Array);

   procedure Write_Word16
     (Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Word : HAL.UInt16);

   procedure Write_Repeated_Word16
     (Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      Word  : HAL.UInt16;
      Count : Positive);

end Glyph.Transport.SPI;
