------------------------------------------------------------------------------
--  Glyph.Framebuffer
--
--  Implementation of static pixel buffer operations and SSD1306 bit math.
------------------------------------------------------------------------------

package body Glyph.Framebuffer is

   procedure Clear (Self : in out Framebuffer) is
   begin
      Self.Data := (others => 0);
   end Clear;

   procedure Set_Pixel
     (Self  : in out Framebuffer;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color) is
      use type Glyph.Types.Coordinate;
      use type Glyph.Types.Byte;

      Page      : Natural;
      Bit_Index : Natural;
      Byte_Idx  : Natural;
      Bit_Mask  : Glyph.Types.Byte;
   begin
      -- Bounds check: ignore out-of-bounds pixels
      if X < 0 or X >= Glyph.Types.Coordinate (Width) or
         Y < 0 or Y >= Glyph.Types.Coordinate (Height)
      then
         return;
      end if;

      -- SSD1306 Page-mode math: 8 vertical pixels per byte
      Page      := Natural (Y) / 8;
      Bit_Index := Natural (Y) rem 8;
      Byte_Idx  := (Page * Natural (Width)) + Natural (X) + 1; -- 1-based Ada array
      Bit_Mask  := Glyph.Types.Byte (2 ** Bit_Index);

      case Color is
         when Glyph.Types.On =>
            Self.Data (Byte_Idx) := Self.Data (Byte_Idx) or Bit_Mask;
         when Glyph.Types.Off =>
            Self.Data (Byte_Idx) := Self.Data (Byte_Idx) and (not Bit_Mask);
         when Glyph.Types.Invert =>
            Self.Data (Byte_Idx) := Self.Data (Byte_Idx) xor Bit_Mask;
      end case;
   end Set_Pixel;

end Glyph.Framebuffer;
