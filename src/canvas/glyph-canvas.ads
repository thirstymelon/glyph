------------------------------------------------------------------------------
--  Glyph.Canvas
--
--  Represents a drawing surface.
--
--  A Canvas stores rendering state and provides the primary drawing API for
--  applications. Drawing operations modify the canvas contents, while Flush
--  transfers the rendered image to the associated display.
------------------------------------------------------------------------------

with Glyph.Types;

package Glyph.Canvas is

   type Canvas
     (Width  : Glyph.Types.Dimension;
      Height : Glyph.Types.Dimension)
   is
     tagged limited private;

   -- procedure Initialize (Self : in out Canvas);
   procedure Clear (Self : in out Canvas);
   procedure Flush (Self : in out Canvas);

private

   type Canvas
     (Width  : Glyph.Types.Dimension;
      Height : Glyph.Types.Dimension)
   is tagged limited record
      null;
   end record;

end Glyph.Canvas;
