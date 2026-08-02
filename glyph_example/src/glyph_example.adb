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

procedure Glyph_Example is

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

   --  Draws a rectangle
   OLED.Canvas.Glow_Line (0, 0, 127, 0, On);       -- top
   OLED.Canvas.Glow_Line (127, 0, 127, 63, On);    -- right
   OLED.Canvas.Glow_Line (127, 63, 0, 63, On);     -- bottom
   OLED.Canvas.Glow_Line (0, 63, 0, 0, On);        -- left

   --  Downward-sloping threads
   OLED.Canvas.Glow_Line (-20, 0, 147, 40, On);
   OLED.Canvas.Glow_Line (-20, 12, 147, 52, On);
   OLED.Canvas.Glow_Line (-20, 24, 147, 64, On);
   OLED.Canvas.Glow_Line (-20, 36, 147, 76, On);
   OLED.Canvas.Glow_Line (-20, 48, 147, 88, On);

   --  Upward-sloping threads
   OLED.Canvas.Glow_Line (-20, 63, 147, 23, On);
   OLED.Canvas.Glow_Line (-20, 51, 147, 11, On);
   OLED.Canvas.Glow_Line (-20, 39, 147, -1, On);
   OLED.Canvas.Glow_Line (-20, 27, 147, -13, On);
   OLED.Canvas.Glow_Line (-20, 15, 147, -25, On);

   OLED.Render;

   loop
      null;
   end loop;
end Glyph_Example;
