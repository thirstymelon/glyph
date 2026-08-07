with Glyph.Types; use Glyph.Types;

generic
   with procedure Put_Pixel (X, Y : Glyph.Types.Coordinate);

package Glyph.Algorithms.Rectangle
is

   procedure Draw (Area : Glyph.Types.Rect);
   procedure Fill (Area : Glyph.Types.Rect);

end Glyph.Algorithms.Rectangle;
