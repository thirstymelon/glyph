package body Glyph.Display_Profiles is

   function Width (Item : Descriptor) return Glyph.Types.Dimension is
   begin
      return Item.Width;
   end Width;

   function Height (Item : Descriptor) return Glyph.Types.Dimension is
   begin
      return Item.Height;
   end Height;

   function Pixel_Format
     (Item : Descriptor) return Glyph.Pixel_Formats.Pixel_Format is
   begin
      return Item.Format;
   end Pixel_Format;

end Glyph.Display_Profiles;
