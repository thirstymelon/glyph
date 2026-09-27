package Glyph.Colors is

   type Monochrome is (Off, On);

   type Grayscale is range 0 .. 255;

   type RGB888 is record
      Red   : Natural range 0 .. 255;
      Green : Natural range 0 .. 255;
      Blue  : Natural range 0 .. 255;
   end record;

end Glyph.Colors;
