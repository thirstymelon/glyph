with Glyph.Types;
with Glyph.Pixel_Formats;

package Glyph.Display_Profiles is

   type Descriptor is private;

   type Controller_Kind is (SSD1306, SH1106, ST7789, ILI9341);
   type Transport_Kind is (I2C, SPI);

   SSD1306_128_64 : constant Descriptor;
   SSD1306_128_32 : constant Descriptor;

   function Width (Item : Descriptor) return Glyph.Types.Dimension;
   function Height (Item : Descriptor) return Glyph.Types.Dimension;

   function Pixel_Format
     (Item : Descriptor) return Glyph.Pixel_Formats.Pixel_Format;

private

   type Descriptor is record
      Width      : Glyph.Types.Dimension;
      Height     : Glyph.Types.Dimension;
      Format     : Glyph.Pixel_Formats.Pixel_Format;
      Controller : Controller_Kind;
      Transport  : Transport_Kind;
   end record;

   SSD1306_128_64 : constant Descriptor :=
     (Width      => 128,
      Height     => 64,
      Format     => Glyph.Pixel_Formats.Monochrome_1bpp,
      Controller => SSD1306,
      Transport  => I2C);

   SSD1306_128_32 : constant Descriptor :=
     (Width      => 128,
      Height     => 32,
      Format     => Glyph.Pixel_Formats.Monochrome_1bpp,
      Controller => SSD1306,
      Transport  => I2C);

end Glyph.Display_Profiles;
