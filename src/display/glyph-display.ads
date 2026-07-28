------------------------------------------------------------------------------
--  Glyph.Display
--
--  Represents a physical display device.
--  Applications interact with displays exclusively through this package.
--  Controller-specific implementations remain internal to Glyph.
------------------------------------------------------------------------------

with Glyph.Types;
with Glyph.Pixel_Formats;
with Glyph.Display_Profiles;

package Glyph.Display is

   type Display is tagged limited private;

   procedure Initialize
     (Self : in out Display; Descriptor : Glyph.Display_Profiles.Descriptor);
   function Is_Initialized (Self : Display) return Boolean;
   procedure Power_On (Self : in out Display);
   procedure Power_Off (Self : in out Display);
   procedure Flush (Self : in out Display);

   function Width (Self : Display) return Glyph.Types.Dimension;
   function Height (Self : Display) return Glyph.Types.Dimension;

   function Pixel_Format
     (Self : Display) return Glyph.Pixel_Formats.Pixel_Format;

private
   Descriptor  : Glyph.Display_Profiles.Descriptor;
   Initialized : Boolean := False;

end Glyph.Display;
