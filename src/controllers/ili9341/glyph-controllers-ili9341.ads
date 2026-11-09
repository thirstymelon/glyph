with HAL.SPI;
with HAL.GPIO;
with Glyph.Colors;
with Glyph.Transport;
with Glyph.Transport.SPI;

package Glyph.Controllers.ILI9341 with
  SPARK_Mode => Off
is

   Native_Width  : constant Positive := 240;
   Native_Height : constant Positive := 320;

   type Orientation_Type is
     (Portrait,
      Landscape,
      Portrait_Inverted,
      Landscape_Inverted);

   type Controller is tagged limited record
      Initialized : Boolean          := False;
      Orientation : Orientation_Type := Portrait;
      Width       : Positive         := Native_Width;
      Height      : Positive         := Native_Height;
   end record;

   procedure Initialize
     (Self  : in out Controller;
      Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Glyph.Transport.SPI.Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      Reset : Glyph.Transport.SPI.Any_GPIO_Point := null);

   procedure Set_Orientation
     (Self        : in out Controller;
      Port        : in out HAL.SPI.SPI_Port'Class;
      CS          : Glyph.Transport.SPI.Any_GPIO_Point;
      DC          : in out HAL.GPIO.GPIO_Point'Class;
      Orientation : Orientation_Type);

   function Current_Width (Self : Controller) return Positive is
     (Self.Width);

   function Current_Height (Self : Controller) return Positive is
     (Self.Height);

   procedure Set_Address_Window
     (Self    : in out Controller;
      Port    : in out HAL.SPI.SPI_Port'Class;
      CS      : Glyph.Transport.SPI.Any_GPIO_Point;
      DC      : in out HAL.GPIO.GPIO_Point'Class;
      X_Start : Natural;
      Y_Start : Natural;
      X_End   : Natural;
      Y_End   : Natural);

   procedure Write_Pixels
     (Self : in out Controller;
      Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Glyph.Transport.SPI.Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Data : Glyph.Transport.Byte_Array);

   procedure Fill_Color
     (Self  : in out Controller;
      Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Glyph.Transport.SPI.Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      Color : Glyph.Colors.RGB565;
      Count : Positive);

   procedure Fill_Rect
     (Self  : in out Controller;
      Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Glyph.Transport.SPI.Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      X     : Natural;
      Y     : Natural;
      W     : Positive;
      H     : Positive;
      Color : Glyph.Colors.RGB565);

   procedure Sleep
     (Self   : in out Controller;
      Port   : in out HAL.SPI.SPI_Port'Class;
      CS     : Glyph.Transport.SPI.Any_GPIO_Point;
      DC     : in out HAL.GPIO.GPIO_Point'Class;
      Enable : Boolean);

   procedure Invert_Display
     (Self   : in out Controller;
      Port   : in out HAL.SPI.SPI_Port'Class;
      CS     : Glyph.Transport.SPI.Any_GPIO_Point;
      DC     : in out HAL.GPIO.GPIO_Point'Class;
      Invert : Boolean);

end Glyph.Controllers.ILI9341;
