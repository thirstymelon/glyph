------------------------------------------------------------------------------
--  Glyph.Display
--
--  Abstract display interface implemented by all display drivers.
--
--  A Display represents a physical display device. It exposes the operations
--  required by Glyph to initialize the hardware, query its capabilities, and
--  present rendered framebuffers.
------------------------------------------------------------------------------

with Glyph.Types;
with Glyph.Pixel_Formats;

package Glyph.Display is

   type Display is abstract tagged limited null record;

   procedure Initialize (Self : in out Display) is abstract;
   procedure Power_On (Self : in out Display) is abstract;
   procedure Power_Off (Self : in out Display) is abstract;
   procedure Flush (Self : in out Display) is abstract;

   function Width (Self : Display) return Glyph.Types.Dimension is abstract;
   function Height (Self : Display) return Glyph.Types.Dimension is abstract;

   function Pixel_Format
     (Self : Display) return Glyph.Pixel_Formats.Pixel_Format
   is abstract;

end Glyph.Display;
