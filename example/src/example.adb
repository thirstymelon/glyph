with RP.GPIO; use RP.GPIO;
with RP.I2C_Master;
with RP.Device;
with RP.Clock;
with Pico;

with Glyph.Display;
with Glyph.Colors;

procedure Example is

   --  Hardware peripheral aliases
   I2C : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   SDA : RP.GPIO.GPIO_Point renames Pico.GP8;
   SCL : RP.GPIO.GPIO_Point renames Pico.GP9;

   --  Instantiate a standard 128x64 SSD1306 display
   --  (standard Framebuffer mode by default)
   OLED : Glyph.Display.Display_T :=
     Glyph.Display.Get_Display (Glyph.Display.SSD1306_128x64_I2C);

   --  Menu Selection: Tile 0 is highlighted
   --  (0: Media, 1: Display, 2: Wifi, 3: Power)
   Selected_Tile : constant Natural := 0;

   --  Bento Tile Geometry Definition
   type Tile_Bounds is record
      X0, Y0 : Integer;
      W, H   : Integer;
   end record;

   type Tile_Array is array (0 .. 3) of Tile_Bounds;
   Grid : constant Tile_Array :=
     ((X0 => 3, Y0 => 2, W => 59, H => 28),   --  Tile 0: Top-Left
      (X0 => 65, Y0 => 2, W => 60, H => 28),   --  Tile 1: Top-Right
      (X0 => 3, Y0 => 34, W => 59, H => 28),   --  Tile 2: Bottom-Left
      (X0 => 65, Y0 => 34, W => 60, H => 28));  --  Tile 3: Bottom-Right

   Is_Selected : Boolean;
   Color_Fg    : Glyph.Colors.Monochrome;

begin

   --  Initialize RP2040 system clocks and hardware timer
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);
   RP.Device.Timer.Enable;

   --  Configure I2C GPIO pins (GP8 / GP9) with pull-ups
   SDA.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);
   SCL.Configure (Output, Pull_Up, RP.GPIO.I2C, Schmitt => True);

   I2C.Configure (Baudrate => 400_000);

   --  Initialize display controller over I2C
   OLED.Init (I2C'Access);

   --  1. Clear Framebuffer
   OLED.Canvas.Clear;

   --  =================================================================
   --  2. Render Bento Box App Menu (2x2 Grid, 128x64)
   --  =================================================================
   for Idx in Grid'Range loop
      Is_Selected := (Idx = Selected_Tile);

      if Is_Selected then
         --  Menu Selector Highlighter: Solid filled inverted card
         OLED.Canvas.Paint_Filled_Rectangle
           (Grid (Idx).X0, Grid (Idx).Y0, Grid (Idx).W, Grid (Idx).H);

         --  Selector Indicator Dot (Top-Right of active tile)
         OLED.Canvas.Paint_Pixel
           (Grid (Idx).X0 + Grid (Idx).W - 6,
            Grid (Idx).Y0 + 6,
            Glyph.Colors.Off);
         OLED.Canvas.Paint_Pixel
           (Grid (Idx).X0 + Grid (Idx).W - 5,
            Grid (Idx).Y0 + 6,
            Glyph.Colors.Off);
         OLED.Canvas.Paint_Pixel
           (Grid (Idx).X0 + Grid (Idx).W - 6,
            Grid (Idx).Y0 + 7,
            Glyph.Colors.Off);
         OLED.Canvas.Paint_Pixel
           (Grid (Idx).X0 + Grid (Idx).W - 5,
            Grid (Idx).Y0 + 7,
            Glyph.Colors.Off);

         Color_Fg := Glyph.Colors.Off;
      else
         --  Unselected Bento Card: Minimalist 1px outline
         OLED.Canvas.Paint_Rectangle
           (Grid (Idx).X0, Grid (Idx).Y0, Grid (Idx).W, Grid (Idx).H);

         Color_Fg := Glyph.Colors.On;
      end if;

      case Idx is
         when 0      =>
            --  TILE 0: AUDIO / MEDIA
            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 5,
               Grid (Idx).Y0 + 5,
               "MEDIA",
               Color => Color_Fg);

            --  Miniature play glyph ▶
            for Y_Off in 0 .. 6 loop
               for X_Off in 0 .. (if Y_Off <= 3 then Y_Off else 6 - Y_Off) loop
                  OLED.Canvas.Paint_Pixel
                    (Grid (Idx).X0 + 5 + X_Off,
                     Grid (Idx).Y0 + 16 + Y_Off,
                     Color_Fg);
               end loop;
            end loop;

            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 14,
               Grid (Idx).Y0 + 16,
               "PLAYING",
               Color => Color_Fg);

         when 1      =>
            --  TILE 1: DISPLAY & BRIGHTNESS
            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 5,
               Grid (Idx).Y0 + 5,
               "DISPLAY",
               Color => Color_Fg);
            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 5,
               Grid (Idx).Y0 + 16,
               "80%",
               Color => Color_Fg);

            --  Minimalist slider gauge
            OLED.Canvas.Paint_Rectangle
              (Grid (Idx).X0 + 28, Grid (Idx).Y0 + 17, 26, 6);
            OLED.Canvas.Paint_Filled_Rectangle
              (Grid (Idx).X0 + 29, Grid (Idx).Y0 + 18, 20, 4);

         when 2      =>
            --  TILE 2: NETWORK / WIFI
            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 5,
               Grid (Idx).Y0 + 5,
               "WIFI",
               Color => Color_Fg);
            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 5,
               Grid (Idx).Y0 + 16,
               "HOME-5G",
               Color => Color_Fg);

            --  Connection indicator dot
            OLED.Canvas.Paint_Filled_Circle
              (Grid (Idx).X0 + Grid (Idx).W - 7, Grid (Idx).Y0 + 19, 2);

         when others =>
            --  TILE 3: POWER / BATTERY
            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 5,
               Grid (Idx).Y0 + 5,
               "POWER",
               Color => Color_Fg);

            --  Battery shell & fill
            OLED.Canvas.Paint_Rectangle
              (Grid (Idx).X0 + 5, Grid (Idx).Y0 + 16, 18, 8);
            OLED.Canvas.Paint_Filled_Rectangle
              (Grid (Idx).X0 + 23, Grid (Idx).Y0 + 18, 2, 4);
            OLED.Canvas.Paint_Filled_Rectangle
              (Grid (Idx).X0 + 7, Grid (Idx).Y0 + 18, 13, 4);

            OLED.Canvas.Paint_Text
              (Grid (Idx).X0 + 28,
               Grid (Idx).Y0 + 16,
               "94%",
               Color => Color_Fg);
      end case;
   end loop;

   --  3. Transmit Complete Framebuffer to Display
   OLED.Render;

   --  Static UI: Idle sleep without any animation
   loop
      RP.Device.Timer.Delay_Milliseconds (1000);
   end loop;

end Example;
