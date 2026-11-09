package body Glyph.Colors with
  SPARK_Mode => On
is

   function To_RGB565 (R, G, B : Natural) return RGB565 is
      R5 : constant RGB565 := RGB565 (R / 8);
      G6 : constant RGB565 := RGB565 (G / 4);
      B5 : constant RGB565 := RGB565 (B / 8);
   begin
      return (R5 * 2048) or (G6 * 32) or B5;
   end To_RGB565;

   function To_RGB565 (Color : RGB888) return RGB565 is
   begin
      return To_RGB565 (Color.Red, Color.Green, Color.Blue);
   end To_RGB565;

   function Red_Channel (Color : RGB565) return Color_Component is
      R5 : constant Natural := Natural (Color / 2048);
   begin
      return (R5 * 255) / 31;
   end Red_Channel;

   function Green_Channel (Color : RGB565) return Color_Component is
      G6 : constant Natural := Natural ((Color / 32) mod 64);
   begin
      return (G6 * 255) / 63;
   end Green_Channel;

   function Blue_Channel (Color : RGB565) return Color_Component is
      B5 : constant Natural := Natural (Color mod 32);
   begin
      return (B5 * 255) / 31;
   end Blue_Channel;

   function To_RGB888 (Color : RGB565) return RGB888 is
   begin
      return
        (Red   => Red_Channel (Color),
         Green => Green_Channel (Color),
         Blue  => Blue_Channel (Color));
   end To_RGB888;

   function Dim (Color : RGB565; Percent : Percentage) return RGB565 is
      Factor : constant Natural := 100 - Percent;
      R5     : constant Natural := Natural (Color / 2048);
      G6     : constant Natural := Natural ((Color / 32) mod 64);
      B5     : constant Natural := Natural (Color mod 32);
      New_R  : constant RGB565 := RGB565 ((R5 * Factor) / 100);
      New_G  : constant RGB565 := RGB565 ((G6 * Factor) / 100);
      New_B  : constant RGB565 := RGB565 ((B5 * Factor) / 100);
   begin
      return (New_R * 2048) or (New_G * 32) or New_B;
   end Dim;

   function Dim (Color : RGB888; Percent : Percentage) return RGB888 is
      Factor : constant Natural := 100 - Percent;
   begin
      return
        (Red   => (Color.Red * Factor) / 100,
         Green => (Color.Green * Factor) / 100,
         Blue  => (Color.Blue * Factor) / 100);
   end Dim;

   function Brighten (Color : RGB565; Percent : Percentage) return RGB565 is
      R5    : constant Natural := Natural (Color / 2048);
      G6    : constant Natural := Natural ((Color / 32) mod 64);
      B5    : constant Natural := Natural (Color mod 32);
      New_R : constant RGB565 := RGB565 (R5 + ((31 - R5) * Percent) / 100);
      New_G : constant RGB565 := RGB565 (G6 + ((63 - G6) * Percent) / 100);
      New_B : constant RGB565 := RGB565 (B5 + ((31 - B5) * Percent) / 100);
   begin
      return (New_R * 2048) or (New_G * 32) or New_B;
   end Brighten;

   function Brighten (Color : RGB888; Percent : Percentage) return RGB888 is
   begin
      return
        (Red   => Color.Red + ((255 - Color.Red) * Percent) / 100,
         Green => Color.Green + ((255 - Color.Green) * Percent) / 100,
         Blue  => Color.Blue + ((255 - Color.Blue) * Percent) / 100);
   end Brighten;

   function Blend
     (Color_A, Color_B : RGB565;
      Weight_A         : Percentage := 50) return RGB565
   is
      Weight_B : constant Natural := 100 - Weight_A;
      R_A      : constant Natural := Natural (Color_A / 2048);
      G_A      : constant Natural := Natural ((Color_A / 32) mod 64);
      B_A      : constant Natural := Natural (Color_A mod 32);
      R_B      : constant Natural := Natural (Color_B / 2048);
      G_B      : constant Natural := Natural ((Color_B / 32) mod 64);
      B_B      : constant Natural := Natural (Color_B mod 32);
      New_R    : constant RGB565 :=
        RGB565 ((R_A * Weight_A + R_B * Weight_B) / 100);
      New_G    : constant RGB565 :=
        RGB565 ((G_A * Weight_A + G_B * Weight_B) / 100);
      New_B    : constant RGB565 :=
        RGB565 ((B_A * Weight_A + B_B * Weight_B) / 100);
   begin
      return (New_R * 2048) or (New_G * 32) or New_B;
   end Blend;

   function Blend
     (Color_A, Color_B : RGB888;
      Weight_A         : Percentage := 50) return RGB888
   is
      Weight_B : constant Natural := 100 - Weight_A;
   begin
      return
        (Red   => (Color_A.Red * Weight_A + Color_B.Red * Weight_B) / 100,
         Green => (Color_A.Green * Weight_A + Color_B.Green * Weight_B) / 100,
         Blue  => (Color_A.Blue * Weight_A + Color_B.Blue * Weight_B) / 100);
   end Blend;

end Glyph.Colors;
