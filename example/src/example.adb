with RP.GPIO; use RP.GPIO;
with RP.I2C_Master;
with RP.Device;
with RP.Clock;
with Pico;

with Glyph.Display;
with Glyph.Types;

procedure Example is

   --  Hardware peripheral aliases
   I2C : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   SDA : RP.GPIO.GPIO_Point renames Pico.GP8;
   SCL : RP.GPIO.GPIO_Point renames Pico.GP9;

   --  Instantiate a standard 128x64 SSD1306 display
   OLED : Glyph.Display.Display_T :=
     Glyph.Display.Get_Display (Glyph.Display.SSD1306_128x64_I2C);

   --  Bouncing HUD box state
   Box_X  : Integer := 62;
   Box_Y  : Integer := 13;
   Step_X : Integer := 1;
   Step_Y : Integer := 1;
   Box_W  : constant := 28;
   Box_H  : constant := 16;

   --  Radar sweep angle in degrees (0..359)
   Radar_Angle : Integer := 0;

   --  Progress meter gauge state
   Meter_Val  : Integer := 2;
   Meter_Step : Integer := 1;

   Frame : Natural := 0;

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
      --  Start each frame with a blank canvas
      OLED.Canvas.Clear;

      --  Screen border & top header bar
      OLED.Canvas.Paint_Rectangle (0, 0, 128, 64);
      OLED.Canvas.Paint_Line (0, 9, 127, 9);

      --  Blinking status heartbeat indicator (top-left)
      if (Frame / 20) mod 2 = 0 then
         OLED.Canvas.Paint_Filled_Circle (6, 4, 2);
      else
         OLED.Canvas.Paint_Circle (6, 4, 2);
      end if;

      --  Battery icon with rounded cap
      OLED.Canvas.Paint_Rectangle (110, 2, 12, 6);
      OLED.Canvas.Paint_Filled_Rectangle (112, 4, 7, 2);
      OLED.Canvas.Paint_Filled_Half_Circle (123, 5, 2, Glyph.Types.Right);

      --  Signal strength bars
      OLED.Canvas.Paint_Line (20, 3, 20, 6);
      OLED.Canvas.Paint_Line (24, 4, 24, 6);
      OLED.Canvas.Paint_Line (28, 4, 28, 6);
      OLED.Canvas.Paint_Line (32, 2, 32, 7);

      --  1. Radar section (left side)
      OLED.Canvas.Paint_Circle (28, 36, 22);
      OLED.Canvas.Paint_Circle (28, 36, 12);
      OLED.Canvas.Paint_Line (6, 36, 50, 36);
      OLED.Canvas.Paint_Line (28, 14, 28, 58);

      --  Sweeping radar beam (pie sector)
      OLED.Canvas.Paint_Filled_Circle
        (Center_X    => 28,
         Center_Y    => 36,
         Radius      => 21,
         Start_Angle => Radar_Angle,
         End_Angle   => (Radar_Angle + 45) mod 360);

      --  Outer orbiting arc
      OLED.Canvas.Paint_Arc
        (Center_X    => 28,
         Center_Y    => 36,
         Radius      => 25,
         Start_Angle => (Radar_Angle * 2) mod 360,
         End_Angle   => (Radar_Angle * 2 + 70) mod 360);

      --  Radar center hub & simulated blips
      OLED.Canvas.Paint_Filled_Circle (28, 36, 2);
      OLED.Canvas.Paint_Pixel (36, 26);
      OLED.Canvas.Paint_Pixel (37, 26);
      OLED.Canvas.Paint_Pixel (20, 44);

      --  2. Bouncing HUD target box with nested chevron triangle
      OLED.Canvas.Paint_Rectangle (Box_X, Box_Y, Box_W, Box_H);
      OLED.Canvas.Paint_Filled_Rectangle (Box_X + 2, Box_Y + 2, 8, Box_H - 4);

      OLED.Canvas.Paint_Triangle
        (X1 => Box_X + 14,
         Y1 => Box_Y + 3,
         X2 => Box_X + 24,
         Y2 => Box_Y + (Box_H / 2),
         X3 => Box_X + 14,
         Y3 => Box_Y + Box_H - 3);

      OLED.Canvas.Paint_Filled_Triangle
        (X1 => Box_X + 16,
         Y1 => Box_Y + 5,
         X2 => Box_X + 21,
         Y2 => Box_Y + (Box_H / 2),
         X3 => Box_X + 16,
         Y3 => Box_Y + Box_H - 5);

      --  3. Dynamic progress gauge with semi-circular caps
      OLED.Canvas.Paint_Rectangle (60, 42, 56, 16);

      if Meter_Val > 0 then
         OLED.Canvas.Paint_Filled_Rectangle (63, 45, Meter_Val, 10);
      end if;

      OLED.Canvas.Paint_Half_Circle (118, 50, 7, Glyph.Types.Right);
      OLED.Canvas.Paint_Filled_Half_Circle (118, 50, 4, Glyph.Types.Right);
      OLED.Canvas.Paint_Filled_Half_Circle (88, 42, 3, Glyph.Types.Top);

      --  Advance animations
      Radar_Angle := (Radar_Angle + 6) mod 360;

      Meter_Val := Meter_Val + Meter_Step;
      if Meter_Val >= 50 or else Meter_Val <= 2 then
         Meter_Step := -Meter_Step;
      end if;

      --  Bounce physics for HUD box
      Box_X := Box_X + Step_X;
      Box_Y := Box_Y + Step_Y;

      if Box_X <= 56 or else Box_X + Box_W >= 126 then
         Step_X := -Step_X;
      end if;

      if Box_Y <= 11 or else Box_Y + Box_H >= 40 then
         Step_Y := -Step_Y;
      end if;

      Frame := Frame + 1;

      --  Push buffer to display and pace the animation loop
      OLED.Render;
      RP.Device.Timer.Delay_Milliseconds (20);
   end loop;

end Example;
