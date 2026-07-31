------------------------------------------------------------------------------
--  Glyph.Controllers.SSD1306
--
--  SSD1306 OLED controller implementation spec.
------------------------------------------------------------------------------

with Glyph.Transports;
with Glyph.Framebuffer;

package Glyph.Controllers.SSD1306 is

   generic
      with package FB is new Glyph.Framebuffer (<>);
   package Driver is

      type Controller (Bus : access Glyph.Transports.Transport'Class) is tagged limited null record;

      procedure Initialize (Self : in out Controller);

      procedure Flush (Self : in out Controller; Buffer : FB.Framebuffer);

   end Driver;

end Glyph.Controllers.SSD1306;
