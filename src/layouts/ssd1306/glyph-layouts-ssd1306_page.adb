------------------------------------------------------------------------------
--  Glyph.Layouts.SSD1306_Page
--
--  SSD1306 page memory mapping.
------------------------------------------------------------------------------

package body Glyph.Layouts.SSD1306_Page is

   function Locate
     (Width : Dimension; X : Coordinate; Y : Coordinate) return Pixel_Location
   is
      Page : constant Natural := Natural (Y) / 8;
   begin
      return
        (Byte_Index => (Page * Natural (Width)) + Natural (X) + 1,
         Bit_Index  => Natural (Y) rem 8);
   end Locate;

end Glyph.Layouts.SSD1306_Page;
