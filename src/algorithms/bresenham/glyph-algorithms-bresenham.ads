------------------------------------------------------------------------------
--  Glyph.Algorithms.Bresenham
--
--  Zero-cost generic Bresenham 2D line rasterization algorithm.
------------------------------------------------------------------------------

with Glyph.Types; use Glyph.Types;

package Glyph.Algorithms.Bresenham is

   --  Generic Bresenham line rasterizer binding Put_Pixel at compile-time
   generic
      with procedure Put_Pixel (X, Y : Coordinate);
   procedure Plot_Line (Target_Line : Line);

end Glyph.Algorithms.Bresenham;
