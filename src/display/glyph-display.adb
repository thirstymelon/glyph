package body Glyph.Display is

   procedure Initialize
     (Self : in out Display; Descriptor : Glyph.Display_Profiles.Descriptor) is
   begin
      Self.Descriptor := Descriptor;
      Self.Initialized := True;
   end Initialize;

   procedure Power_On (Self : in out Display) is
   begin
      pragma Unreferenced (Self);

      -- TODO: Forward to Glyph.Controllers.
      null;
   end Power_On;

   procedure Power_Off (Self : in out Display) is
   begin
      pragma Unreferenced (Self);

      -- TODO: Forward to Glyph.Controllers.
      null;
   end Power_Off;

   procedure Flush (Self : in out Display) is
   begin
      pragma Unreferenced (Self);

      -- TODO: Forward framebuffer to controller.
      null;
   end Flush;

   function Width (Self : Display) return Glyph.Types.Dimension is
   begin
      return Glyph.Display_Profiles.Width (Self.Descriptor);
   end Width;

   function Height (Self : Display) return Glyph.Types.Dimension is
   begin
      return Glyph.Display_Profiles.Height (Self.Descriptor);
   end Height;

   function Pixel_Format
     (Self : Display) return Glyph.Pixel_Formats.Pixel_Format is
   begin
      return Glyph.Display_Profiles.Pixel_Format (Self.Descriptor);
   end Pixel_Format;

   function Is_Initialized (Self : Display) return Boolean is
   begin
      return Self.Initialized;
   end Is_Initialized;

end Glyph.Display;
