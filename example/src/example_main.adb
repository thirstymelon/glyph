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

   --  SSD1306 OLED Music Player Design ("Sailor Song" by Gigi Perez)
   procedure Draw_SSD1306 (Frame : Natural) is
      use Ada.Numerics;
      use Ada.Numerics.Elementary_Functions;

      Phase : constant Float := Float (Frame mod 60) * (2.0 * Pi / 60.0);

      --  Spool rotation angles (both spools spin steadily)
      Spool_Ang : constant Float := Phase * 3.0;

      --  Smooth full-width timeline scrubber (X: 4 .. 122)
      Scrub_X : constant Integer := 4 + (Frame mod 60) * 118 / 59;

      procedure Draw_Spool (CX, CY : Integer) is
      begin
         OLED.Paint_Circle (CX, CY, 4);
         OLED.Paint_Filled_Circle (CX, CY, 1);

         --  3 rotating spokes per spool
         for S in 0 .. 2 loop
            declare
               Spoke_Ang : constant Float :=
                 Spool_Ang + Float (S) * (2.0 * Pi / 3.0);
               SX        : constant Integer :=
                 CX + Integer (3.0 * Cos (Spoke_Ang));
               SY        : constant Integer :=
                 CY + Integer (3.0 * Sin (Spoke_Ang));
            begin
               OLED.Paint_Line (CX, CY, SX, SY);
            end;
         end loop;
      end Draw_Spool;

   begin
      OLED.Clear;

      --  Top Status Bar
      OLED.Paint_Text (4, 1, "> PLAY");
      OLED.Paint_Text (52, 1, "VOL ||.");
      OLED.Paint_Text (96, 1, "FLAC");
      OLED.Paint_Line (0, 9, 127, 9);

      --  Left Side: Retro-Modern Cassette Tape (X: 4..40, Y: 13..45)
      --  Outer cassette shell
      OLED.Paint_Rectangle (4, 13, 38, 29);
      --  Inner tape window
      OLED.Paint_Rectangle (10, 18, 26, 14);

      --  Tape spools
      Draw_Spool (16, 25);
      Draw_Spool (30, 25);

      --  Magnetic tape guide line
      OLED.Paint_Line (16, 29, 30, 29);

      --  Cassette bottom trapezoid bevel
      OLED.Paint_Line (10, 42, 14, 38);
      OLED.Paint_Line (14, 38, 28, 38);
      OLED.Paint_Line (28, 38, 32, 42);

      --  Right Side: Song Information
      OLED.Paint_Text (48, 13, "SAILOR SONG");
      OLED.Paint_Text (48, 22, "GIGI PEREZ");

      --  Dynamic 8-Channel Audio Spectrum Equalizer (X: 48..124, Y: 33..43)
      for B in 0 .. 7 loop
         declare
            Band_F : constant Float := Float (B) * 0.85 + Phase * 3.0;
            H_Raw  : constant Float := (Sin (Band_F) + 1.0) / 2.0;
            H      : constant Integer := 2 + Integer (H_Raw * 8.0);
            Bar_X  : constant Integer := 48 + B * 5;
         begin
            OLED.Paint_Filled_Rectangle (Bar_X, 43 - H, 3, H);
         end;
      end loop;

      --  Sampling rate badge
      OLED.Paint_Text (94, 34, "48kHz");

      --  Bottom Section: Full-Width Scrubber & Controls
      --  Scrubber track & moving playhead
      OLED.Paint_Line (4, 49, 123, 49);
      OLED.Paint_Line (4, 49, Scrub_X, 49);
      OLED.Paint_Filled_Rectangle (Scrub_X - 1, 47, 3, 5);

      --  Timestamps & transport indicators
      OLED.Paint_Text (4, 55, "01:14");
      OLED.Paint_Text (46, 55, "|<<  ||  >>|");
      OLED.Paint_Text (92, 55, "-02:37");
   end Draw_SSD1306;

   --  ILI9341 240x320 16-bit Color Calculator Design
   procedure Draw_ILI9341 (Frame : Natural) is
      use Ada.Numerics.Elementary_Functions;

      --  Palette
      C_Body     : constant Glyph.Colors.RGB565 := 16#10E2#;
      C_LCD_BG   : constant Glyph.Colors.RGB565 := 16#08A3#;
      C_LCD_Edge : constant Glyph.Colors.RGB565 := 16#2187#;
      C_Num_Key  : constant Glyph.Colors.RGB565 := 16#1946#;
      C_Num_Edge : constant Glyph.Colors.RGB565 := 16#29C8#;
      C_Fn_Key   : constant Glyph.Colors.RGB565 := 16#2A0C#;
      C_Op_Key   : constant Glyph.Colors.RGB565 := 16#FA80#;
      C_Active   : constant Glyph.Colors.RGB565 := 16#07FF#;
      C_White    : constant Glyph.Colors.RGB565 := 16#FFFF#;
      C_Muted    : constant Glyph.Colors.RGB565 := 16#7BCF#;
      C_Green    : constant Glyph.Colors.RGB565 := 16#07E0#;

      Step : constant Natural := Frame mod 60;

      Active_R : Integer := -1;
      Active_C : Integer := -1;

      procedure Draw_Key
        (R, C   : Natural;
         Label  : String;
         Kind   : Natural; -- 0: Num, 1: Fn, 2: Op
         Active : Boolean)
      is
         KX : constant Integer := 8 + C * 58;
         KY : constant Integer := 96 + R * 44;
         KW : constant Integer := 50;
         KH : constant Integer := 38;

         Fill_Col : Glyph.Colors.RGB565;
         Text_Col : Glyph.Colors.RGB565;
         Text_X   : Integer;
         Text_Y   : constant Integer := KY + 15;
      begin
         if Active then
            Fill_Col := (if Kind = 2 then C_White else C_Active);
            Text_Col := 16#0000#;
         else
            case Kind is
               when 1      =>
                  Fill_Col := C_Fn_Key;
                  Text_Col := C_Active;

               when 2      =>
                  Fill_Col := C_Op_Key;
                  Text_Col := C_White;

               when others =>
                  Fill_Col := C_Num_Key;
                  Text_Col := C_White;
            end case;
         end if;

         --  Key body & border
         TFT.Paint_Filled_Rectangle (KX, KY, KW, KH, Fill_Col);
         TFT.Paint_Rectangle
           (KX, KY, KW, KH, Color => (if Active then C_White else C_Num_Edge));

         --  Center text
         Text_X := KX + (KW - Label'Length * 6) / 2;
         TFT.Paint_Text (Text_X, Text_Y, Label, Color => Text_Col);
      end Draw_Key;

   begin
      --  Determine currently pressed key
      if Step < 15 then
         Active_R := 3;
         Active_C := 1; -- '2'
      elsif Step < 30 then
         Active_R := 1;
         Active_C := 3; -- '*'
      elsif Step < 45 then
         Active_R := 3;
         Active_C := 2; -- '3'
      else
         Active_R := 4;
         Active_C := 3; -- '='
      end if;

      TFT.Clear (C_Body);

      --  Top LCD Screen Region (Y: 8 .. 88)
      TFT.Paint_Filled_Rectangle (8, 8, 224, 80, C_LCD_BG);
      TFT.Paint_Rectangle
        (8, 8, 224, 80, Color => (if Step >= 45 then C_Green else C_LCD_Edge));

      --  Top status row in LCD
      TFT.Paint_Text (16, 14, "DEG", Color => C_Muted);
      TFT.Paint_Text (50, 14, "FIX:2", Color => C_Muted);

      --  Mini graphing LCD wave on top-right
      for WX in 0 .. 36 loop
         declare
            Wave_Ang : constant Float :=
              Float (WX) * 0.25 + Float (Step) * 0.1047;
            WY       : constant Integer := 18 + Integer (4.0 * Sin (Wave_Ang));
         begin
            TFT.Paint_Pixel (176 + WX, WY, Color => C_Active);
         end;
      end loop;

      --  Formula history line
      if Step < 15 then
         TFT.Paint_Text (16, 32, "ENTER VALUE:", Color => C_Muted);
      elsif Step < 30 then
         TFT.Paint_Text (16, 32, "240 * ...", Color => C_Muted);
      elsif Step < 45 then
         TFT.Paint_Text (16, 32, "240 * 3 =", Color => C_Muted);
      else
         TFT.Paint_Text (16, 32, "240 * 3 = 720.00", Color => C_Green);
      end if;

      --  Main Number Display
      if Step < 15 then
         TFT.Paint_Text (16, 54, "240", Scale => 2, Color => C_White);
      elsif Step < 30 then
         TFT.Paint_Text (16, 54, "240 *", Scale => 2, Color => C_Active);
      elsif Step < 45 then
         TFT.Paint_Text (16, 54, "3", Scale => 2, Color => C_White);
      else
         TFT.Paint_Text (16, 54, "720.00", Scale => 2, Color => C_White);
      end if;

      --  Blinking cursor
      if (Step mod 20) < 10 then
         declare
            Cur_X : constant Integer :=
              (if Step < 15
               then 64
               elsif Step < 30
               then 88
               elsif Step < 45
               then 38
               else 106);
         begin
            TFT.Paint_Filled_Rectangle (Cur_X, 54, 3, 14, C_Active);
         end;
      end if;

      --  Keypad Buttons (5 rows x 4 columns)
      --  Row 0: Functions
      Draw_Key (0, 0, "AC", 1, Active_R = 0 and then Active_C = 0);
      Draw_Key (0, 1, "( )", 1, Active_R = 0 and then Active_C = 1);
      Draw_Key (0, 2, "%", 1, Active_R = 0 and then Active_C = 2);
      Draw_Key (0, 3, "/", 2, Active_R = 0 and then Active_C = 3);

      --  Row 1
      Draw_Key (1, 0, "7", 0, Active_R = 1 and then Active_C = 0);
      Draw_Key (1, 1, "8", 0, Active_R = 1 and then Active_C = 1);
      Draw_Key (1, 2, "9", 0, Active_R = 1 and then Active_C = 2);
      Draw_Key (1, 3, "*", 2, Active_R = 1 and then Active_C = 3);

      --  Row 2
      Draw_Key (2, 0, "4", 0, Active_R = 2 and then Active_C = 0);
      Draw_Key (2, 1, "5", 0, Active_R = 2 and then Active_C = 1);
      Draw_Key (2, 2, "6", 0, Active_R = 2 and then Active_C = 2);
      Draw_Key (2, 3, "-", 2, Active_R = 2 and then Active_C = 3);

      --  Row 3
      Draw_Key (3, 0, "1", 0, Active_R = 3 and then Active_C = 0);
      Draw_Key (3, 1, "2", 0, Active_R = 3 and then Active_C = 1);
      Draw_Key (3, 2, "3", 0, Active_R = 3 and then Active_C = 2);
      Draw_Key (3, 3, "+", 2, Active_R = 3 and then Active_C = 3);

      --  Row 4
      Draw_Key (4, 0, "0", 0, Active_R = 4 and then Active_C = 0);
      Draw_Key (4, 1, ".", 0, Active_R = 4 and then Active_C = 1);
      Draw_Key (4, 2, "DEL", 1, Active_R = 4 and then Active_C = 2);
      Draw_Key (4, 3, "=", 2, Active_R = 4 and then Active_C = 3);
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
