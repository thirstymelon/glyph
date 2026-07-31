------------------------------------------------------------------------------
--  Proof of Work: Single Pixel Rendering Example
--
--  This example demonstrates the complete vertical slice of Glyph:
--  1. Implements a mock/hardware I2C Transport.
--  2. Instantiates the SSD1306 128x64 display composite.
--  3. Sets a single pixel at (X=10, Y=10).
--  4. Flushes the 1024-byte buffer payload.
------------------------------------------------------------------------------

with Glyph.Types; use Glyph.Types;
with Glyph.Transports;
with Glyph.Displays.SSD1306_128x64_I2C;

procedure Proof_Of_Work is

   -- Mock/Stub Transport simulating the RP2040 I2C output
   type Test_I2C_Transport is new Glyph.Transports.Transport with record
      Bytes_Sent : Natural := 0;
   end record;

   overriding
   procedure Send
     (Self : in out Test_I2C_Transport;
      Kind : Glyph.Transports.Data_Kind;
      Data : Glyph.Types.Byte_Array) is
   begin
      Self.Bytes_Sent := Self.Bytes_Sent + Data'Length;
   end Send;

   overriding
   procedure Reset (Self : in out Test_I2C_Transport) is
   begin
      null;
   end Reset;

   -- Instantiate transport & display
   Bus  : aliased Test_I2C_Transport;
   OLED : Glyph.Displays.SSD1306_128x64_I2C.Device (Bus => Bus'Access);

begin
   -- Initialize display controller
   OLED.Initialize;

   -- Vertical Slice Goal: Render a single pixel at X=10, Y=10!
   OLED.Canvas.Draw_Pixel (X => 10, Y => 10, Color => On);

   -- Flush framebuffer to display hardware
   OLED.Render;

end Proof_Of_Work;
