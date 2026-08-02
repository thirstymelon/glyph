------------------------------------------------------------------------------
--  Glyph.Controllers.SSD1306
--
--  Initialization sequence and page-mode data transmission for SSD1306 OLED.
------------------------------------------------------------------------------

with Glyph.Types; use Glyph.Types;

package body Glyph.Controllers.SSD1306 is

   package body Driver is

      --  SSD1306 I2C Initialization Command Sequence
      Init_Cmds : constant Glyph.Types.Byte_Array :=
        (16#AE#,        -- Display OFF
         16#D5#, 16#80#, -- Set Display Clock Divide Ratio / Oscillator Frequency
         16#A8#, 16#3F#, -- Set Multiplex Ratio (1 to 64 -> 0x3F = 63)
         16#D3#, 16#00#, -- Set Display Offset
         16#40#,        -- Set Display Start Line (0)
         16#8D#, 16#14#, -- Charge Pump Setting (Enable charge pump 0x14)
         16#20#, 16#00#, -- Memory Addressing Mode: Horizontal Addressing Mode (0x00)
         16#A1#,        -- Set Segment Re-map (A1 = column address 127 is mapped to SEG0)
         16#C8#,        -- Set COM Output Scan Direction (C8 = remapped mode)
         16#DA#, 16#12#, -- Set COM Pins Hardware Configuration
         16#81#, 16#CF#, -- Set Contrast Control
         16#D9#, 16#F1#, -- Set Pre-charge Period
         16#DB#, 16#40#, -- Set VCOMH Deselect Level
         16#A4#,        -- Entire Display ON (Follow RAM content)
         16#A6#,        -- Set Normal Display (non-inverted)
         16#AF#         -- Display ON
        );

      -- Column & Page Pointer Reset for Horizontal Addressing Mode
      Set_Bounds_Cmds : constant Glyph.Types.Byte_Array :=
        (16#21#, 16#00#, 16#7F#,  -- Set Column Address Range (0 to 127)
         16#22#, 16#00#, 16#07#   -- Set Page Address Range (0 to 7)
        );

      procedure Initialize (Self : in out Controller) is
      begin
         Self.Bus.Send (Kind => Glyph.Transports.Command, Data => Init_Cmds);
      end Initialize;

      procedure Flush (Self : in out Controller; Buffer : FB.Framebuffer) is
      begin
         -- 1. Reset hardware cursor pointer to Top-Left (0, 0)
         Self.Bus.Send (Kind => Glyph.Transports.Command, Data => Set_Bounds_Cmds);

         -- 2. Transmit the 1024-byte pixel payload
         Self.Bus.Send
           (Kind => Glyph.Transports.Pixel_Data,
            Data => Glyph.Types.Byte_Array (Buffer.Data));
      end Flush;

   end Driver;

end Glyph.Controllers.SSD1306;
