------------------------------------------------------------------------------
--  Glyph.Canvas
--
--  Represents a drawing surface.
--
--  A Canvas stores rendering state and provides the primary drawing API for
--  applications. Drawing operations modify the canvas contents, while Flush
--  transfers the rendered image to the associated display.
------------------------------------------------------------------------------

package Glyph.Canvas is

   type Canvas is tagged limited private;

   procedure Clear (Self : in out Canvas);

private

   type Canvas is tagged limited null record;

end Glyph.Canvas;
