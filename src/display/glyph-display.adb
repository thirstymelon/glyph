package body Glyph.Display is

   procedure Initialize
     (Self : in out Display; Descriptor : Glyph.Display_Profiles.Descriptor) is
   begin
      null;
   end Initialize;

   function Is_Initialized (Self : Display) return Boolean is
   begin
      null;
   end Is_Initialized;

   procedure Power_On (Self : in out Display) is
   begin
      null;
   end Power_On;

   procedure Power_Off (Self : in out Display) is
   begin
      null;
   end Power_Off;

   procedure Flush (Self : in out Display) is
   begin
      null;
   end Flush;

   function Width (Self : Display) return Glyph.Types.Dimension is
   begin
      null;
   end Width;

   function Height (Self : Display) return Glyph.Types.Dimension is
   begin
      null;
   end Height;

   function Pixel_Format
     (Self : Display) return Glyph.Pixel_Formats.Pixel_Format is
   begin
      null;
   end Pixel_Format;

end Glyph.Display;
