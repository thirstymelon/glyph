with RP.GPIO; use RP.GPIO;
with RP.I2C_Master;
with RP.Device;
with RP.Clock;
with Pico;

with Glyph.Display;

procedure Example is

   --  Hardware peripheral aliases
   I2C : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   SDA : RP.GPIO.GPIO_Point renames Pico.GP8;
   SCL : RP.GPIO.GPIO_Point renames Pico.GP9;

   --  Instantiate a standard 128x64 SSD1306 display
   OLED : Glyph.Display.Display_T :=
     Glyph.Display.Get_Display (Glyph.Display.SSD1306_128x64_I2C);

   --  Animation state
   Disk_Angle : Natural := 0;
   Progress   : Natural := 12;
   Step       : Integer := 1;
   Frame      : Natural := 0;

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

   loop
      --  1. Clear canvas for next frame
      OLED.Canvas.Clear;

      --  2. Main Hero Element: Large Rotating Vinyl Record (Center: 32, 32)
      --  Outer rim & concentric sound grooves (R: 28, 23, 18, 13)
      OLED.Canvas.Paint_Circle (32, 32, 28);
      OLED.Canvas.Paint_Circle (32, 32, 23);
      OLED.Canvas.Paint_Circle (32, 32, 18);
      OLED.Canvas.Paint_Circle (32, 32, 13);

      --  Dual dynamic glossy sheen arcs rotating with the record
      OLED.Canvas.Paint_Arc
        (Center_X    => 32,
         Center_Y    => 32,
         Radius      => 21,
         Start_Angle => Disk_Angle,
         End_Angle   => (Disk_Angle + 45) mod 360);

      OLED.Canvas.Paint_Arc
        (Center_X    => 32,
         Center_Y    => 32,
         Radius      => 16,
         Start_Angle => (Disk_Angle + 180) mod 360,
         End_Angle   => (Disk_Angle + 225) mod 360);

      --  Center record label & spindle hole
      OLED.Canvas.Paint_Circle (32, 32, 8);
      OLED.Canvas.Paint_Filled_Circle (32, 32, 3);
      OLED.Canvas.Paint_Pixel (32, 32);

      --  Delicate tonearm resting on the record groove
      OLED.Canvas.Paint_Filled_Circle (61, 6, 2);
      OLED.Canvas.Paint_Line (61, 6, 54, 18);
      OLED.Canvas.Paint_Line (54, 18, 47, 24);

      --  3. Right Side: Minimal Track Typography
      OLED.Canvas.Paint_Text (67, 13, "Sailor");
      OLED.Canvas.Paint_Text (67, 23, "Song");
      OLED.Canvas.Paint_Text (67, 35, "Gigi Perez");

      --  4. Playback State & Progress Bar
      OLED.Canvas.Paint_Filled_Triangle (67, 47, 67, 53, 72, 50);
      OLED.Canvas.Paint_Text (76, 47, "1:24");

      --  Slim progress line with scrubber dot
      OLED.Canvas.Paint_Line (67, 57, 122, 57);
      OLED.Canvas.Paint_Filled_Circle (67 + Progress, 57, 2);

      --  5. Advance animation state
      Disk_Angle := (Disk_Angle + 8) mod 360;

      if Frame mod 4 = 0 then
         Progress := Progress + Step;
         if Progress >= 54 or else Progress <= 2 then
            Step := -Step;
         end if;
      end if;

      Frame := Frame + 1;

      --  6. Transmit frame to OLED display
      OLED.Render;
      RP.Device.Timer.Delay_Milliseconds (20);
   end loop;

end Example;
