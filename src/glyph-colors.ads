package Glyph.Colors with
  SPARK_Mode => On
is

   type Monochrome is (Off, On);

   type Grayscale is range 0 .. 255;

   type RGB888 is record
      Red   : Natural range 0 .. 255;
      Green : Natural range 0 .. 255;
      Blue  : Natural range 0 .. 255;
   end record;

   --  16-bit RGB565 (5 bits Red, 6 bits Green, 5 bits Blue)
   type RGB565 is mod 2 ** 16;

   --  Color conversion utilities
   function To_RGB565 (R, G, B : Natural) return RGB565 with
     Pre => R <= 255 and then G <= 255 and then B <= 255;

   function To_RGB565 (Color : RGB888) return RGB565;

   function To_RGB888 (Color : RGB565) return RGB888;

   subtype Color_Component is Natural range 0 .. 255;

   --  Component extraction (scaled to 0 .. 255)
   function Red_Channel (Color : RGB565) return Color_Component;
   function Green_Channel (Color : RGB565) return Color_Component;
   function Blue_Channel (Color : RGB565) return Color_Component;

   --  Standard predefined RGB565 colors
   Black       : constant RGB565 := 16#0000#;
   White       : constant RGB565 := 16#FFFF#;
   Red         : constant RGB565 := 16#F800#;
   Green       : constant RGB565 := 16#07E0#;
   Blue        : constant RGB565 := 16#001F#;
   Yellow      : constant RGB565 := 16#FFE0#;
   Cyan        : constant RGB565 := 16#07FF#;
   Magenta     : constant RGB565 := 16#F81F#;
   Orange      : constant RGB565 := 16#FD20#;
   Navy        : constant RGB565 := 16#000F#;
   Dark_Green  : constant RGB565 := 16#03E0#;
   Dark_Cyan   : constant RGB565 := 16#03EF#;
   Maroon      : constant RGB565 := 16#7800#;
   Purple      : constant RGB565 := 16#780F#;
   Olive       : constant RGB565 := 16#7BE0#;
   Light_Grey  : constant RGB565 := 16#C618#;
   Dark_Grey   : constant RGB565 := 16#7BEF#;

   --  Color manipulation
   subtype Percentage is Natural range 0 .. 100;

   --  Dims the color by reducing its brightness by Percent % (0% = unchanged, 100% = Black)
   function Dim (Color : RGB565; Percent : Percentage) return RGB565;
   function Dim (Color : RGB888; Percent : Percentage) return RGB888;

   --  Brightens the color towards White by Percent % (0% = unchanged, 100% = White)
   function Brighten (Color : RGB565; Percent : Percentage) return RGB565;
   function Brighten (Color : RGB888; Percent : Percentage) return RGB888;

   --  Linearly blends between Color_A and Color_B using Weight_A percentage (0..100)
   function Blend
     (Color_A, Color_B : RGB565;
      Weight_A         : Percentage := 50) return RGB565;

   function Blend
     (Color_A, Color_B : RGB888;
      Weight_A         : Percentage := 50) return RGB888;

end Glyph.Colors;
