------------------------------------------------------------------------------
--  Glyph.Canvas
--
--  Represents a drawing surface.
--
--  A Canvas stores rendering state and provides the primary drawing API for
--  applications. Drawing operations modify the canvas contents, while Flush
--  transfers the rendered image to the associated display.
------------------------------------------------------------------------------

with Glyph.Display;

package Glyph.Canvas is

   type Canvas is tagged limited private;

   procedure Attach
     (Self    : in out Canvas;
      Display : not null access Glyph.Display.Display'Class);
   procedure Clear (Self : in out Canvas);
   procedure Flush (Self : in out Canvas);

private

   type Canvas is tagged limited record
      Display : access Glyph.Display.Display'Class := null;
   end record;

end Glyph.Canvas;
