------------------------------------------------------------------------------
--  Glyph.Framebuffer
--
--  Implementation.
------------------------------------------------------------------------------

with Glyph.Layouts;
with Glyph.Layouts.SSD1306_Page;

package body Glyph.Framebuffer is

   procedure Clear (Self : in out Framebuffer) is
   begin
      Self.Data := (others => 0);
   end Clear;

   procedure Set_Pixel
     (Self  : in out Framebuffer;
      X     : Glyph.Types.Coordinate;
      Y     : Glyph.Types.Coordinate;
      Color : Glyph.Types.Pixel_Color)
   is
      use type Glyph.Types.Coordinate;
      use type Glyph.Types.Byte;

      Location : Glyph.Layouts.Pixel_Location;
      Bit_Mask : Glyph.Types.Byte;
   begin

      if X < 0
        or else X >= Glyph.Types.Coordinate (Width)
        or else Y < 0
        or else Y >= Glyph.Types.Coordinate (Height)
      then
         return;
      end if;

      Location :=
        Glyph.Layouts.SSD1306_Page.Locate (Width => Width, X => X, Y => Y);

      Bit_Mask := Glyph.Types.Byte (2 ** Location.Bit_Index);

      case Color is
         when Glyph.Types.On     =>
            Self.Data (Location.Byte_Index) :=
              Self.Data (Location.Byte_Index) or Bit_Mask;

         when Glyph.Types.Off    =>
            Self.Data (Location.Byte_Index) :=
              Self.Data (Location.Byte_Index) and (not Bit_Mask);

         when Glyph.Types.Invert =>
            Self.Data (Location.Byte_Index) :=
              Self.Data (Location.Byte_Index) xor Bit_Mask;
      end case;

   end Set_Pixel;

end Glyph.Framebuffer;
