------------------------------------------------------------------------------
--  Glyph.Types
--
--  Common types used throughout the Glyph graphics framework.
--
--  This package defines the fundamental data types shared by graphics,
--  displays, framebuffers, and other library components.
------------------------------------------------------------------------------

package Glyph.Types is

   subtype Coordinate is Integer;
   subtype Dimension is Positive;
   subtype Pixel_Index is Natural;

   type Rotation is (Rotate_0, Rotate_90, Rotate_180, Rotate_270);

end Glyph.Types;
