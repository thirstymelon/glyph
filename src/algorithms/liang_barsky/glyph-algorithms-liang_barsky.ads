------------------------------------------------------------------------------
--  Glyph.Algorithms.Liang_Barsky
--
--  Liang-Barsky line clipping algorithm.
------------------------------------------------------------------------------

with Glyph.Types; use Glyph.Types;

package Glyph.Algorithms.Liang_Barsky is

   function Clip_Line
     (Target_Line : in out Line; Clip_Rect : Rect) return Boolean;

end Glyph.Algorithms.Liang_Barsky;
