------------------------------------------------------------------------------
--  Glyph.Layouts.SSD1306_Page
--
--  Maps pixel coordinates to the SSD1306 page-oriented framebuffer layout.
------------------------------------------------------------------------------

with Glyph.Types; use Glyph.Types;

package Glyph.Layouts.SSD1306_Page is

   function Locate
     (Width : Dimension; X : Coordinate; Y : Coordinate) return Pixel_Location;

end Glyph.Layouts.SSD1306_Page;
