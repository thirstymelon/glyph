with RP.GPIO; use RP.GPIO;
with RP.I2C_Master;
with RP.SPI;
with RP.Device;
with RP.Clock;
with HAL.I2C;
with Pico;

with Glyph.Colors;
with Glyph.Fonts;
with Glyph.Display.SSD1306;
with Glyph.Display.ILI9341;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;

procedure Example_Main is

   --  Hardware peripherals for RP2040:
   --  SSD1306: GP8 (SDA), GP9 (SCL) on I2C0
   I2C : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   SDA : RP.GPIO.GPIO_Point renames Pico.GP8;
   SCL : RP.GPIO.GPIO_Point renames Pico.GP9;

   --  ILI9341: GP18 (SCK), GP19 (MOSI), GP16 (MISO), GP17 (CS) on SPI0
   --  Control pins: GP20 (DC), GP21 (Reset)
   SPI   : RP.SPI.SPI_Port renames RP.Device.SPI_0;
   SCK   : RP.GPIO.GPIO_Point renames Pico.GP18;
   MOSI  : RP.GPIO.GPIO_Point renames Pico.GP19;
   MISO  : RP.GPIO.GPIO_Point renames Pico.GP16;
   CS    : RP.GPIO.GPIO_Point renames Pico.GP17;
   DC    : RP.GPIO.GPIO_Point renames Pico.GP20;
   Reset : RP.GPIO.GPIO_Point renames Pico.GP21;

   --  Display instances
   OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
   TFT  : Glyph.Display.ILI9341.Display_T := Glyph.Display.ILI9341.Create;

   Current_Frame : Natural := 0;

   --  SSD1306 demo animation
   procedure Draw_SSD1306 (Frame : Natural) is
      use Ada.Numerics;
      use Ada.Numerics.Elementary_Functions;

      Progress : constant Integer := (Frame mod 30) * 104 / 29;
      Radius   : constant Integer := 6 + (Frame mod 12);
      Ang      : constant Float := Float (Frame mod 24) * (2.0 * Pi / 24.0);
      Dot_X    : constant Integer := 64 + Integer (22.0 * Cos (Ang));
      Dot_Y    : constant Integer := 28 + Integer (15.0 * Sin (Ang));
   begin
      OLED.Clear;

      --  Border frame
      OLED.Paint_Rectangle (0, 0, 128, 64);

      --  Header
      OLED.Paint_Text (6, 4, "GLYPH OLED");

      --  Pulsing concentric circles in center
      OLED.Paint_Circle (64, 28, Radius);
      OLED.Paint_Filled_Circle (64, 28, 3);

      --  Orbiting dot
      OLED.Paint_Filled_Rectangle (Dot_X - 1, Dot_Y - 1, 3, 3);

      --  Progress bar
      OLED.Paint_Rectangle (10, 48, 108, 8);
      if Progress > 0 then
         OLED.Paint_Filled_Rectangle (12, 50, Progress, 4);
      end if;
   end Draw_SSD1306;

   --  ILI9341 demo animation
   procedure Draw_ILI9341 (Frame : Natural) is
      use Ada.Numerics;
      use Ada.Numerics.Elementary_Functions;

      C_Dark_Blue : constant Glyph.Colors.RGB565 := 16#0810#;
      C_Cyan      : constant Glyph.Colors.RGB565 := 16#07FF#;
      C_Orange    : constant Glyph.Colors.RGB565 := 16#FD20#;
      C_Yellow    : constant Glyph.Colors.RGB565 := 16#FFE0#;
      C_Green     : constant Glyph.Colors.RGB565 := 16#07E0#;
      C_White     : constant Glyph.Colors.RGB565 := 16#FFFF#;
      C_Slate     : constant Glyph.Colors.RGB565 := 16#29A6#;

      --  Bouncing ball 1
      Ball1_X : constant Integer := 30 + ((Frame * 9) mod 180);
      Ball1_Y : constant Integer := 70 + ((Frame * 7) mod 70);

      --  Bouncing ball 2
      Ball2_X : constant Integer := 210 - ((Frame * 8) mod 180);
      Ball2_Y : constant Integer := 130 - ((Frame * 6) mod 60);

      --  Center spinner
      Spin_Ang : constant Float :=
        Float (Frame mod 24) * (2.0 * Pi / 24.0);
      Hand_X   : constant Integer := 120 + Integer (32.0 * Cos (Spin_Ang));
      Hand_Y   : constant Integer := 185 + Integer (32.0 * Sin (Spin_Ang));

      --  Progress bar (0 .. 196 px)
      Progress : constant Integer := (Frame mod 30) * 196 / 29;

   begin
      TFT.Clear (16#0000#);

      --  Header
      TFT.Paint_Filled_Rectangle (0, 0, 240, 36, C_Dark_Blue);
      TFT.Paint_Line (0, 36, 239, 36, C_Cyan);
      TFT.Paint_Text (20, 12, "GLYPH DISPLAY DEMO", Color => C_White);

      --  Bouncing colored circles
      TFT.Paint_Filled_Circle (Ball1_X, Ball1_Y, 14, Color => C_Cyan);
      TFT.Paint_Filled_Circle (Ball2_X, Ball2_Y, 12, Color => C_Orange);

      --  Center dial spinner
      TFT.Paint_Circle (120, 185, 36, Color => C_Slate);
      TFT.Paint_Line (120, 185, Hand_X, Hand_Y, C_Yellow);
      TFT.Paint_Filled_Circle (120, 185, 4, Color => C_White);

      --  Bottom Progress bar
      TFT.Paint_Text (20, 244, "LOADING...", Color => C_White);
      TFT.Paint_Rectangle (20, 260, 200, 16, Color => C_Slate);
      if Progress > 0 then
         TFT.Paint_Filled_Rectangle (22, 262, Progress, 12, C_Green);
      end if;
   end Draw_ILI9341;

   --  Status LEDs (GP4 and Pico GP25)
   LED_A : RP.GPIO.GPIO_Point renames Pico.GP4;
   LED_B : RP.GPIO.GPIO_Point renames Pico.GP25;

   procedure Set_LEDs (State : Boolean) is
   begin
      if State then
         LED_A.Set;
         LED_B.Set;
      else
         LED_A.Clear;
         LED_B.Clear;
      end if;
   end Set_LEDs;

begin
   --  Clock and timer setup
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);
   RP.Device.Timer.Enable;

   LED_A.Configure (Output, Floating, RP.GPIO.SIO);
   LED_B.Configure (Output, Floating, RP.GPIO.SIO);
   Set_LEDs (True);

   --  SSD1306 OLED (I2C0)
   SDA.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);
   SCL.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);

   I2C.Configure (Baudrate => 400_000);
   RP.Device.Timer.Delay_Milliseconds (50);

   --  Check for 0x3C or 0x3D slave address
   declare
      use type HAL.I2C.I2C_Status;
      use type HAL.I2C.I2C_Address;
      Status : HAL.I2C.I2C_Status;
      Dummy  : constant HAL.I2C.I2C_Data (1 .. 1) := (1 => 16#E3#); -- NOP
      Found  : HAL.I2C.I2C_Address := 0;
   begin
      I2C.Master_Transmit (16#78#, Dummy, Status, Timeout => 20);
      if Status = HAL.I2C.Ok then
         Found := 16#3C#;
      else
         I2C.Master_Transmit (16#7A#, Dummy, Status, Timeout => 20);
         if Status = HAL.I2C.Ok then
            Found := 16#3D#;
         else
            for A in 16#08# .. 16#77# loop
               I2C.Master_Transmit
                 (HAL.I2C.I2C_Address (A * 2), Dummy, Status, Timeout => 10);
               if Status = HAL.I2C.Ok then
                  Found := HAL.I2C.I2C_Address (A);
                  exit;
               end if;
            end loop;
         end if;
      end if;

      if Found /= 0 then
         OLED.Set_Address (Found);
      else
         OLED.Set_Address (16#3C#);
      end if;
   end;

   OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
   OLED.Init (I2C'Access);
   RP.Device.Timer.Delay_Milliseconds (50);

   Draw_SSD1306 (0);
   OLED.Render (Force => True);

   --  ILI9341 TFT (SPI0)
   SCK.Configure (Output, Floating, RP.GPIO.SPI);
   MOSI.Configure (Output, Floating, RP.GPIO.SPI);
   MISO.Configure (Input, Floating, RP.GPIO.SPI);

   CS.Configure (Output, Floating, RP.GPIO.SIO);
   DC.Configure (Output, Floating, RP.GPIO.SIO);
   Reset.Configure (Output, Floating, RP.GPIO.SIO);

   CS.Set;
   DC.Set;
   Reset.Set;

   SPI.Configure
     (Config =>
        (Role     => RP.SPI.Master,
         Baud     => 16_000_000,
         Polarity => RP.SPI.Active_Low,
         Phase    => RP.SPI.Rising_Edge,
         others   => <>));

   TFT.Set_Default_Font (Glyph.Fonts.Font_5x7);
   TFT.Init
     (SPI   => SPI'Access,
      DC    => DC'Access,
      CS    => CS'Access,
      Reset => Reset'Access);

   --  Main loop
   loop
      Set_LEDs ((Current_Frame mod 10) < 5);

      Draw_SSD1306 (Current_Frame);
      OLED.Render;

      Draw_ILI9341 (Current_Frame);
      TFT.Render;

      Current_Frame := Current_Frame + 1;
      RP.Device.Timer.Delay_Milliseconds (40);
   end loop;

end Example_Main;
