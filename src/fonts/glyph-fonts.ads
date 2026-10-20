with Glyph.Transport;

package Glyph.Fonts is

   type Glyph_Data is array (Positive range <>) of Glyph.Transport.Byte;

   type Font is record
      Width      : Positive;
      Height     : Positive;
      First_Char : Character;
      Last_Char  : Character;
      Data       : access constant Glyph_Data;
   end record;

   function Font_5x7 return Font;

   function Glyph_Width (F : Font) return Positive
   is (F.Width);
   function Glyph_Height (F : Font) return Positive
   is (F.Height);

end Glyph.Fonts;
