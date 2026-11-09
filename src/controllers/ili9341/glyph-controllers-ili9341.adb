with HAL;

package body Glyph.Controllers.ILI9341 with
  SPARK_Mode => Off
is

   use Glyph.Transport;
   use Glyph.Transport.SPI;

   --  ILI9341 Command Definitions
   CMD_SWRESET : constant Byte := 16#01#;
   CMD_SLPOUT  : constant Byte := 16#11#;
   CMD_DISPOFF : constant Byte := 16#28#;
   CMD_DISPON  : constant Byte := 16#29#;
   CMD_CASET   : constant Byte := 16#2A#;
   CMD_PASET   : constant Byte := 16#2B#;
   CMD_RAMWR   : constant Byte := 16#2C#;
   CMD_INVOFF  : constant Byte := 16#20#;
   CMD_INVON   : constant Byte := 16#21#;
   CMD_MADCTL  : constant Byte := 16#36#;
   CMD_COLMOD  : constant Byte := 16#3A#;

   --  Extended Registers
   CMD_PWCTRA  : constant Byte := 16#CB#;
   CMD_PWCTRB  : constant Byte := 16#CF#;
   CMD_DTCTRA  : constant Byte := 16#E8#;
   CMD_DTCTRB  : constant Byte := 16#EA#;
   CMD_POSC    : constant Byte := 16#ED#;
   CMD_PRC     : constant Byte := 16#F7#;
   CMD_PWCTR1  : constant Byte := 16#C0#;
   CMD_PWCTR2  : constant Byte := 16#C1#;
   CMD_VMCTR1  : constant Byte := 16#C5#;
   CMD_VMCTR2  : constant Byte := 16#C7#;
   CMD_FRMCTR1 : constant Byte := 16#B1#;
   CMD_DFUNCTR : constant Byte := 16#B6#;
   CMD_3GENBL  : constant Byte := 16#F2#;
   CMD_GAMMASET: constant Byte := 16#26#;
   CMD_GMCTRP1 : constant Byte := 16#E0#;
   CMD_GMCTRN1 : constant Byte := 16#E1#;

   procedure Initialize
     (Self  : in out Controller;
      Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Glyph.Transport.SPI.Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      Reset : Glyph.Transport.SPI.Any_GPIO_Point := null)
   is
   begin
      --  Hardware reset if pin provided
      if Reset /= null then
         Reset.Set;
         Reset.Clear;
         Reset.Set;
      end if;

      --  Software Reset
      Write_Command (Port, CS, DC, CMD_SWRESET);

      --  Power Control A
      Write_Command (Port, CS, DC, CMD_PWCTRA);
      Write_Data (Port, CS, DC, [16#39#, 16#2C#, 16#00#, 16#34#, 16#02#]);

      --  Power Control B
      Write_Command (Port, CS, DC, CMD_PWCTRB);
      Write_Data (Port, CS, DC, [16#00#, 16#C1#, 16#30#]);

      --  Driver Timing Control A
      Write_Command (Port, CS, DC, CMD_DTCTRA);
      Write_Data (Port, CS, DC, [16#85#, 16#00#, 16#78#]);

      --  Driver Timing Control B
      Write_Command (Port, CS, DC, CMD_DTCTRB);
      Write_Data (Port, CS, DC, [16#00#, 16#00#]);

      --  Power on Sequence Control
      Write_Command (Port, CS, DC, CMD_POSC);
      Write_Data (Port, CS, DC, [16#64#, 16#03#, 16#12#, 16#81#]);

      --  Pump Ratio Control
      Write_Command (Port, CS, DC, CMD_PRC);
      Write_Data_Byte (Port, CS, DC, 16#20#);

      --  Power Control 1
      Write_Command (Port, CS, DC, CMD_PWCTR1);
      Write_Data_Byte (Port, CS, DC, 16#23#);

      --  Power Control 2
      Write_Command (Port, CS, DC, CMD_PWCTR2);
      Write_Data_Byte (Port, CS, DC, 16#10#);

      --  VCOM Control 1
      Write_Command (Port, CS, DC, CMD_VMCTR1);
      Write_Data (Port, CS, DC, [16#3E#, 16#28#]);

      --  VCOM Control 2
      Write_Command (Port, CS, DC, CMD_VMCTR2);
      Write_Data_Byte (Port, CS, DC, 16#86#);

      --  Pixel Format: 16-bit RGB565 (0x55)
      Write_Command (Port, CS, DC, CMD_COLMOD);
      Write_Data_Byte (Port, CS, DC, 16#55#);

      --  Frame Rate Control
      Write_Command (Port, CS, DC, CMD_FRMCTR1);
      Write_Data (Port, CS, DC, [16#00#, 16#18#]);

      --  Display Function Control
      Write_Command (Port, CS, DC, CMD_DFUNCTR);
      Write_Data (Port, CS, DC, [16#08#, 16#82#, 16#27#]);

      --  3Gamma Function Disable
      Write_Command (Port, CS, DC, CMD_3GENBL);
      Write_Data_Byte (Port, CS, DC, 16#00#);

      --  Gamma curve selected
      Write_Command (Port, CS, DC, CMD_GAMMASET);
      Write_Data_Byte (Port, CS, DC, 16#01#);

      --  Positive Gamma Correction
      Write_Command (Port, CS, DC, CMD_GMCTRP1);
      Write_Data
        (Port, CS, DC,
         [16#0F#, 16#31#, 16#2B#, 16#0C#, 16#0E#, 16#08#, 16#4E#, 16#F1#,
          16#37#, 16#07#, 16#10#, 16#03#, 16#0E#, 16#09#, 16#00#]);

      --  Negative Gamma Correction
      Write_Command (Port, CS, DC, CMD_GMCTRN1);
      Write_Data
        (Port, CS, DC,
         [16#00#, 16#0E#, 16#14#, 16#03#, 16#11#, 16#07#, 16#31#, 16#C1#,
          16#48#, 16#08#, 16#0F#, 16#0C#, 16#31#, 16#36#, 16#0F#]);

      --  Set initial orientation
      Self.Set_Orientation (Port, CS, DC, Self.Orientation);

      --  Exit Sleep Mode
      Write_Command (Port, CS, DC, CMD_SLPOUT);

      --  Turn on Display
      Write_Command (Port, CS, DC, CMD_DISPON);

      Self.Initialized := True;
   end Initialize;

   procedure Set_Orientation
     (Self        : in out Controller;
      Port        : in out HAL.SPI.SPI_Port'Class;
      CS          : Glyph.Transport.SPI.Any_GPIO_Point;
      DC          : in out HAL.GPIO.GPIO_Point'Class;
      Orientation : Orientation_Type)
   is
      Madctl_Val : Byte;
   begin
      Self.Orientation := Orientation;

      case Orientation is
         when Portrait =>
            Madctl_Val  := 16#48#;
            Self.Width  := Native_Width;
            Self.Height := Native_Height;
         when Landscape =>
            Madctl_Val  := 16#28#;
            Self.Width  := Native_Height;
            Self.Height := Native_Width;
         when Portrait_Inverted =>
            Madctl_Val  := 16#88#;
            Self.Width  := Native_Width;
            Self.Height := Native_Height;
         when Landscape_Inverted =>
            Madctl_Val  := 16#E8#;
            Self.Width  := Native_Height;
            Self.Height := Native_Width;
      end case;

      Write_Command (Port, CS, DC, CMD_MADCTL);
      Write_Data_Byte (Port, CS, DC, Madctl_Val);
   end Set_Orientation;

   procedure Set_Address_Window
     (Self    : in out Controller;
      Port    : in out HAL.SPI.SPI_Port'Class;
      CS      : Glyph.Transport.SPI.Any_GPIO_Point;
      DC      : in out HAL.GPIO.GPIO_Point'Class;
      X_Start : Natural;
      Y_Start : Natural;
      X_End   : Natural;
      Y_End   : Natural)
   is
      pragma Unreferenced (Self);
      C_Buf : constant Byte_Array (1 .. 4) :=
        [1 => Byte (X_Start / 256),
         2 => Byte (X_Start mod 256),
         3 => Byte (X_End / 256),
         4 => Byte (X_End mod 256)];
      P_Buf : constant Byte_Array (1 .. 4) :=
        [1 => Byte (Y_Start / 256),
         2 => Byte (Y_Start mod 256),
         3 => Byte (Y_End / 256),
         4 => Byte (Y_End mod 256)];
   begin
      Write_Command (Port, CS, DC, CMD_CASET);
      Write_Data (Port, CS, DC, C_Buf);

      Write_Command (Port, CS, DC, CMD_PASET);
      Write_Data (Port, CS, DC, P_Buf);

      Write_Command (Port, CS, DC, CMD_RAMWR);
   end Set_Address_Window;

   procedure Write_Pixels
     (Self : in out Controller;
      Port : in out HAL.SPI.SPI_Port'Class;
      CS   : Glyph.Transport.SPI.Any_GPIO_Point;
      DC   : in out HAL.GPIO.GPIO_Point'Class;
      Data : Glyph.Transport.Byte_Array)
   is
      pragma Unreferenced (Self);
   begin
      Write_Data (Port, CS, DC, Data);
   end Write_Pixels;

   procedure Fill_Color
     (Self  : in out Controller;
      Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Glyph.Transport.SPI.Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      Color : Glyph.Colors.RGB565;
      Count : Positive)
   is
      pragma Unreferenced (Self);
   begin
      Write_Repeated_Word16 (Port, CS, DC, HAL.UInt16 (Color), Count);
   end Fill_Color;

   procedure Fill_Rect
     (Self  : in out Controller;
      Port  : in out HAL.SPI.SPI_Port'Class;
      CS    : Glyph.Transport.SPI.Any_GPIO_Point;
      DC    : in out HAL.GPIO.GPIO_Point'Class;
      X     : Natural;
      Y     : Natural;
      W     : Positive;
      H     : Positive;
      Color : Glyph.Colors.RGB565)
   is
      X_End : constant Natural := X + W - 1;
      Y_End : constant Natural := Y + H - 1;
      Count : constant Positive := W * H;
   begin
      Self.Set_Address_Window (Port, CS, DC, X, Y, X_End, Y_End);
      Self.Fill_Color (Port, CS, DC, Color, Count);
   end Fill_Rect;

   procedure Sleep
     (Self   : in out Controller;
      Port   : in out HAL.SPI.SPI_Port'Class;
      CS     : Glyph.Transport.SPI.Any_GPIO_Point;
      DC     : in out HAL.GPIO.GPIO_Point'Class;
      Enable : Boolean)
   is
      pragma Unreferenced (Self);
   begin
      if Enable then
         Write_Command (Port, CS, DC, CMD_DISPOFF);
      else
         Write_Command (Port, CS, DC, CMD_SLPOUT);
         Write_Command (Port, CS, DC, CMD_DISPON);
      end if;
   end Sleep;

   procedure Invert_Display
     (Self   : in out Controller;
      Port   : in out HAL.SPI.SPI_Port'Class;
      CS     : Glyph.Transport.SPI.Any_GPIO_Point;
      DC     : in out HAL.GPIO.GPIO_Point'Class;
      Invert : Boolean)
   is
      pragma Unreferenced (Self);
   begin
      if Invert then
         Write_Command (Port, CS, DC, CMD_INVON);
      else
         Write_Command (Port, CS, DC, CMD_INVOFF);
      end if;
   end Invert_Display;

end Glyph.Controllers.ILI9341;
