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

   --  SSD1306 Bento Menu (Home, Music, Settings, Alarm with Active Highlight)
   procedure Draw_SSD1306 (Frame : Natural) is
      use Glyph.Colors;

      --  4-State Selection Cycle (15 frames each = 60 frames total)
      Sel : constant Natural := (Frame / 15) mod 4;

      procedure Draw_Pixel
        (X, Y : Integer; Col : Glyph.Colors.Monochrome) is
      begin
         OLED.Paint_Pixel (X, Y, Col);
      end Draw_Pixel;

      procedure Draw_HLine
        (X, Y, W : Integer; Col : Glyph.Colors.Monochrome) is
      begin
         for I in 0 .. W - 1 loop
            OLED.Paint_Pixel (X + I, Y, Col);
         end loop;
      end Draw_HLine;

      procedure Draw_VLine
        (X, Y, H : Integer; Col : Glyph.Colors.Monochrome) is
      begin
         for I in 0 .. H - 1 loop
            OLED.Paint_Pixel (X, Y + I, Col);
         end loop;
      end Draw_VLine;

      procedure Draw_Line
        (X1, Y1, X2, Y2 : Integer; Col : Glyph.Colors.Monochrome)
      is
         DX  : constant Integer := abs (X2 - X1);
         DY  : constant Integer := abs (Y2 - Y1);
         SX  : constant Integer := (if X1 < X2 then 1 else -1);
         SY  : constant Integer := (if Y1 < Y2 then 1 else -1);
         Err : Integer := DX - DY;
         CX  : Integer := X1;
         CY  : Integer := Y1;
         E2  : Integer;
      begin
         loop
            OLED.Paint_Pixel (CX, CY, Col);
            exit when CX = X2 and then CY = Y2;
            E2 := 2 * Err;
            if E2 > -DY then
               Err := Err - DY;
               CX  := CX + SX;
            end if;
            if E2 < DX then
               Err := Err + DX;
               CY  := CY + SY;
            end if;
         end loop;
      end Draw_Line;
   begin
      OLED.Clear;

      --  Top Header Bar (Clean & Minimal)
      OLED.Paint_Text (5, 1, "09:41", Color => On);

      --  Battery indicator on the right
      OLED.Paint_Rectangle (108, 1, 14, 7);
      OLED.Paint_Pixel (122, 3, On);
      OLED.Paint_Pixel (122, 4, On);
      OLED.Paint_Pixel (122, 5, On);
      OLED.Paint_Filled_Rectangle (110, 3, 9, 3);

      --  Header divider line
      OLED.Paint_Line (3, 9, 124, 9);

      --  1. Top-Left Bento Card: HOME (X=3..53, Y=12..34)
      declare
         Active : constant Boolean := (Sel = 0);
         Fg     : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (3, 12, 51, 23);
         else
            OLED.Paint_Rectangle (3, 12, 51, 23);
         end if;

         --  Chimney on the roof (X=16)
         Draw_VLine (16, 16, 4, Fg);

         --  House Roof (Peak at 14, 17)
         Draw_Line (14, 17, 10, 21, Fg);
         Draw_Line (14, 17, 18, 21, Fg);
         Draw_HLine (10, 21, 9, Fg);

         --  House Body & Base
         Draw_VLine (11, 21, 6, Fg);
         Draw_VLine (17, 21, 6, Fg);
         Draw_HLine (11, 26, 7, Fg);

         --  Door
         Draw_VLine (13, 23, 4, Fg);
         Draw_VLine (15, 23, 4, Fg);
         Draw_HLine (13, 23, 3, Fg);

         --  Animated Chimney Smoke and Lit Window when Active
         if Active then
            declare
               S1_Y : constant Integer := 15 - ((Frame mod 6) * 3 / 4);
               S1_X : constant Integer := 16 + ((Frame mod 6) / 2);
               S2_Y : constant Integer := 15 - (((Frame + 3) mod 6) * 3 / 4);
               S2_X : constant Integer := 16 + (((Frame + 3) mod 6) / 2);
            begin
               if S1_Y >= 13 then
                  Draw_Pixel (S1_X, S1_Y, Fg);
               end if;
               if S2_Y >= 13 then
                  Draw_Pixel (S2_X, S2_Y, Fg);
               end if;
            end;
            --  Lit Attic Window in gable
            Draw_Pixel (14, 19, Fg);
         end if;

         OLED.Paint_Text (23, 19, "HOME", Color => Fg);
      end;

      --  2. Top-Right Bento Card: MUSIC (X=56..124, Y=12..34)
      declare
         Active  : constant Boolean := (Sel = 1);
         Fg      : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
         NX      : constant Integer := 69;
         Phase_M : constant Natural := Frame mod 8;
         --  Syncopated bobbing of the two note heads
         B1      : constant Integer :=
           (if Active and then (Phase_M in 2 .. 5) then 1 else 0);
         B2      : constant Integer :=
           (if Active and then (Phase_M in 0 .. 1 or else Phase_M in 6 .. 7)
            then 1 else 0);
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (56, 12, 69, 23);
         else
            OLED.Paint_Rectangle (56, 12, 69, 23);
         end if;

         --  Double Beamed Note Icon (Dancing to the beat when active)
         --  Stem 1 and Head 1 (bobs with B1)
         Draw_VLine (NX + 2, 18 - B1, 7, Fg);
         Draw_HLine (NX, 24 - B1, 4, Fg);
         Draw_HLine (NX, 25 - B1, 4, Fg);

         --  Stem 2 and Head 2 (bobs with B2)
         Draw_VLine (NX + 7, 17 - B2, 7, Fg);
         Draw_HLine (NX + 5, 23 - B2, 4, Fg);
         Draw_HLine (NX + 5, 24 - B2, 4, Fg);

         --  Connecting dynamic top beam (follows both note heads)
         Draw_Line (NX + 2, 18 - B1, NX + 7, 17 - B2, Fg);
         Draw_Line (NX + 2, 19 - B1, NX + 7, 18 - B2, Fg);

         --  Radiating sound vibration accent when active
         if Active and then (Phase_M mod 4 < 2) then
            Draw_Pixel (NX + 9, 15 - B2, Fg);
            Draw_Pixel (NX + 10, 14 - B2, Fg);
         end if;

         --  Centered Text (X=83, baseline matches note head at Y=25)
         OLED.Paint_Text (83, 19, "MUSIC", Color => Fg);
      end;

      --  3. Bottom-Left Bento Card: ALARM (X=3..53, Y=38..60)
      declare
         Active : constant Boolean := (Sel = 3);
         Fg     : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
         AX     : constant Integer := 8;
         AY     : constant Integer := 45;
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (3, 38, 51, 23);
         else
            OLED.Paint_Rectangle (3, 38, 51, 23);
         end if;

         --  Twin-Bell Alarm Clock Icon (Width: 9, Height: 8)
         --  Top bells & snooze button (Row 0..1)
         Draw_HLine (AX, AY, 2, Fg);
         Draw_HLine (AX + 7, AY, 2, Fg);
         Draw_Pixel (AX + 1, AY + 1, Fg);
         Draw_Pixel (AX + 4, AY + 1, Fg);
         Draw_Pixel (AX + 7, AY + 1, Fg);

         --  Round Clock Body (Row 2..6)
         Draw_HLine (AX + 2, AY + 2, 5, Fg);
         Draw_Pixel (AX + 1, AY + 3, Fg);
         Draw_Pixel (AX + 7, AY + 3, Fg);
         Draw_Pixel (AX + 1, AY + 4, Fg);
         Draw_Pixel (AX + 7, AY + 4, Fg);
         Draw_Pixel (AX + 1, AY + 5, Fg);
         Draw_Pixel (AX + 7, AY + 5, Fg);
         Draw_HLine (AX + 2, AY + 6, 5, Fg);

         --  Clock Hands (12:15 - hour hand up, minute hand right)
         Draw_Pixel (AX + 4, AY + 3, Fg);
         Draw_HLine (AX + 4, AY + 4, 2, Fg);

         --  Clock Feet (Row 7)
         Draw_Pixel (AX + 1, AY + 7, Fg);
         Draw_Pixel (AX + 7, AY + 7, Fg);

         --  Ringing vibration waves when active
         if Active and then (Frame mod 4 < 2) then
            Draw_Pixel (AX - 2, AY, Fg);
            Draw_Pixel (AX - 2, AY + 1, Fg);
            Draw_Pixel (AX + 10, AY, Fg);
            Draw_Pixel (AX + 10, AY + 1, Fg);
         end if;

         OLED.Paint_Text (21, 46, "ALARM", Color => Fg);
      end;

      --  4. Bottom-Right Bento Card: SETTINGS (X=56..124, Y=38..60)
      declare
         Active : constant Boolean := (Sel = 2);
         Fg     : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
         SX     : constant Integer := 61;
         K1     : constant Integer :=
           (if Active then SX + 2 + ((Frame mod 15) / 3) else SX + 3);
         K2     : constant Integer :=
           (if Active then SX + 8 - ((Frame mod 15) / 3) else SX + 7);
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (56, 38, 69, 23);
         else
            OLED.Paint_Rectangle (56, 38, 69, 23);
         end if;

         --  Slider 1 Track & Knob
         Draw_HLine (SX, 44, 11, Fg);
         Draw_VLine (K1, 42, 5, Fg);
         Draw_VLine (K1 + 1, 42, 5, Fg);

         --  Slider 2 Track & Knob
         Draw_HLine (SX, 52, 11, Fg);
         Draw_VLine (K2, 50, 5, Fg);
         Draw_VLine (K2 + 1, 50, 5, Fg);

         OLED.Paint_Text (75, 46, "SETTINGS", Color => Fg);
      end;
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
