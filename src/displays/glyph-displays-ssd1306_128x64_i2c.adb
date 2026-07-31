------------------------------------------------------------------------------
--  Glyph.Displays.SSD1306_128x64_I2C
--
--  Implementation of composite Device operations.
------------------------------------------------------------------------------

package body Glyph.Displays.SSD1306_128x64_I2C is

   procedure Initialize (Self : in out Device) is
   begin
      Self.Canvas.Buffer := Self.Buffer'Unchecked_Access;
      Self.Controller.Initialize;
   end Initialize;

   procedure Render (Self : in out Device) is
   begin
      Self.Controller.Flush (Self.Buffer);
   end Render;

end Glyph.Displays.SSD1306_128x64_I2C;
