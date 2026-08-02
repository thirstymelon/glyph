------------------------------------------------------------------------------
--  Glyph.Algorithms.Bresenham
--
--  Bresenham line rasterization algorithm.
------------------------------------------------------------------------------

with Glyph.Types; use Glyph.Types;

package Glyph.Algorithms.Bresenham is

   generic
      with procedure Put_Pixel (X, Y : Coordinate);
   procedure Plot_Line (Target_Line : Line);

end Glyph.Algorithms.Bresenham;
