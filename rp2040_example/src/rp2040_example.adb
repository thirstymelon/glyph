------------------------------------------------------------------------------
--  Vicharak Shrike-Lite (RP2040) + SSD1306 OLED Single-Pixel Proof of Work
--
--  Feel free to use other RP2040 dev boards
------------------------------------------------------------------------------

with RP.GPIO; use RP.GPIO;
with RP.I2C_Master;
with RP.Device;
with RP.Clock;
with Pico;

with Glyph.Types; use Glyph.Types;
with Glyph.Displays.SSD1306_128x64_I2C;
with Glue;

procedure Rp2040_Example is

   --  Vicharak Shrike-Lite Left Header I2C0 Pins:
   --  IO8 (RP_IO8) = I2C0 SDA, IO9 (RP_IO9) = I2C0 SCL
   Port : RP.I2C_Master.I2C_Master_Port renames RP.Device.I2CM_0;
   SDA  : RP.GPIO.GPIO_Point renames Pico.GP8;
   SCL  : RP.GPIO.GPIO_Point renames Pico.GP9;

   I2C_Bus : aliased Glue.Pico_I2C_Transport (Port_Ptr => Port'Access);
   OLED    : Glyph.Displays.SSD1306_128x64_I2C.Device (Bus => I2C_Bus'Access);

begin
   RP.Clock.Initialize (Pico.XOSC_Frequency);
   RP.Clock.Enable (RP.Clock.PERI);

   SDA.Configure (Output, Floating, RP.GPIO.I2C, Schmitt => True);
   SCL.Configure (Output, Floating, RP.GPIO.I2C, Schmitt => True);
   Port.Configure (Baudrate => 400_000);

   OLED.Initialize;
   OLED.Canvas.Clear;

   -- Outer border
   OLED.Canvas.Glow_Rectangle
     (Area  =>
        (Min_Point => (X => 0, Y => 0), Max_Point => (X => 127, Y => 63)),
      Color => On);

   -- Concentric rectangles
   OLED.Canvas.Glow_Rectangle
     (Area  =>
        (Min_Point => (X => 8, Y => 4), Max_Point => (X => 119, Y => 59)),
      Color => On);

   OLED.Canvas.Glow_Rectangle
     (Area  =>
        (Min_Point => (X => 16, Y => 8), Max_Point => (X => 111, Y => 55)),
      Color => On);

   OLED.Canvas.Glow_Rectangle
     (Area  =>
        (Min_Point => (X => 24, Y => 12), Max_Point => (X => 103, Y => 51)),
      Color => On);

   -- Center cross
   OLED.Canvas.Glow_Line (0, 31, 127, 31, On);
   OLED.Canvas.Glow_Line (63, 0, 63, 63, On);

   -- Diagonals
   OLED.Canvas.Glow_Line (0, 0, 127, 63, On);
   OLED.Canvas.Glow_Line (0, 63, 127, 0, On);

   -- Filled center
   OLED.Canvas.Glow_Filled_Rectangle
     (Area  =>
        (Min_Point => (X => 54, Y => 22), Max_Point => (X => 72, Y => 40)),
      Color => On);

   -- Corner pixels
   OLED.Canvas.Glow_Pixel (50, 18, On);
   OLED.Canvas.Glow_Pixel (50, 44, On);
   OLED.Canvas.Glow_Pixel (76, 44, On);
   OLED.Canvas.Glow_Pixel (76, 18, On);

   OLED.Render;

   loop
      null;
   end loop;
end Rp2040_Example;
