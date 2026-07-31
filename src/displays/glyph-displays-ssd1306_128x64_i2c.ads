------------------------------------------------------------------------------
--  Glyph.Displays.SSD1306_128x64_I2C
--
--  High-level composite API bundling Framebuffer, Canvas, and Controller.
------------------------------------------------------------------------------

with Glyph.Transports;
with Glyph.Framebuffer;
with Glyph.Canvas;
with Glyph.Controllers.SSD1306;

package Glyph.Displays.SSD1306_128x64_I2C is

   package FB_128x64 is new Glyph.Framebuffer (Width => 128, Height => 64);
   package Canvas_128x64 is new Glyph.Canvas (FB => FB_128x64);
   package Controller_128x64 is new Glyph.Controllers.SSD1306.Driver (FB => FB_128x64);

   type Device (Bus : access Glyph.Transports.Transport'Class) is tagged limited record
      Buffer     : aliased FB_128x64.Framebuffer;
      Canvas     : Canvas_128x64.Drawing_Canvas;
      Controller : Controller_128x64.Controller (Bus => Bus);
   end record;

   procedure Initialize (Self : in out Device);

   procedure Render (Self : in out Device);

end Glyph.Displays.SSD1306_128x64_I2C;
