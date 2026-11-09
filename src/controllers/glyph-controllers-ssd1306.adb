with Glyph.Transport.I2C;

package body Glyph.Controllers.SSD1306 with
  SPARK_Mode => Off
is

   use Glyph.Transport;


   --  Complete SSD1306 & SH1106 Initialization Command Stream
   --  Byte 1 is Control Byte: Co=0, D/C#=0 (all subsequent bytes are commands)
   Init_Commands : constant Glyph.Transport.Byte_Array :=
     (1  => 16#00#,  --  Control Byte: Command Stream
      2  => 16#AE#,  --  Display Off (Sleep)
      3  => 16#D5#,
      4  => 16#80#,  --  Set Display Clock Divide Ratio / Osc Freq
      5  => 16#A8#,
      6  => 16#3F#,  --  Set Multiplex Ratio (64 MUX)
      7  => 16#D3#,
      8  => 16#00#,  --  Set Display Offset (0)
      9  => 16#40#,  --  Set Display Start Line (0)
      10 => 16#8D#,
      11 => 16#14#,  --  SSD1306: Enable Charge Pump Regulator (7.5V)
      12 => 16#AD#,
      13 => 16#8B#,  --  SH1106: Enable Internal DC-DC Pump
      14 => 16#20#,
      15 => 16#00#,  --  Set Memory Addressing Mode: Horizontal
      16 => 16#A1#,  --  Set Segment Re-map (COL127 -> SEG0)
      17 => 16#C8#,  --  Set COM Output Scan Direction (COM63 -> COM0)
      18 => 16#DA#,
      19 => 16#12#,  --  Set COM Pins Hardware Configuration
      20 => 16#81#,
      21 => 16#CF#,  --  Set Contrast Control
      22 => 16#D9#,
      23 => 16#F1#,  --  Set Pre-charge Period
      24 => 16#DB#,
      25 => 16#40#,  --  Set VCOMH Deselect Level
      26 => 16#2E#,  --  Deactivate Scroll
      27 => 16#A4#,  --  Resume to RAM Content
      28 => 16#A6#,  --  Normal Display (Non-inverted)
      29 => 16#AF#); --  Display On

   procedure Set_Address
     (Self : in out Controller; Address : HAL.I2C.I2C_Address) is
   begin
      Self.Address := Address;
   end Set_Address;

   function Get_Address
     (Self : Controller) return HAL.I2C.I2C_Address is
   begin
      return Self.Address;
   end Get_Address;

   procedure Initialize
     (Self : in out Controller; Bus : in out HAL.I2C.I2C_Port'Class) is
   begin
      Glyph.Transport.I2C.I2C_Write
        (Bus => Bus, Address => Self.Address, Data => Init_Commands);
      Self.Initialized := True;
   end Initialize;

   procedure Set_Address_Window
     (Self       : in out Controller;
      Bus        : in out HAL.I2C.I2C_Port'Class;
      Col_Start  : Natural;
      Col_End    : Natural;
      Page_Start : Natural;
      Page_End   : Natural) is
   begin
      if not Self.Initialized then
         raise Program_Error;
      end if;

      Glyph.Transport.I2C.I2C_Write
        (Bus     => Bus,
         Address => Self.Address,
         Data    =>
           (1 => 16#00#,
            2 => 16#21#,
            3 => Byte (Col_Start),
            4 => Byte (Col_End),
            5 => 16#22#,
            6 => Byte (Page_Start),
            7 => Byte (Page_End)));
   end Set_Address_Window;

   procedure Write_Data
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class;
      Data : Glyph.Transport.Byte_Array) is
   begin
      if not Self.Initialized then
         raise Program_Error;
      end if;

      Glyph.Transport.I2C.I2C_Write
        (Bus => Bus, Address => Self.Address, Data => Data);
   end Write_Data;

   procedure Flush
     (Self : in out Controller;
      Bus  : in out HAL.I2C.I2C_Port'Class;
      Data : Glyph.Transport.Byte_Array) is
   begin
      if not Self.Initialized then
         raise Program_Error;
      end if;

      declare
         Page_Buf : Glyph.Transport.Byte_Array (1 .. 1 + 128);
         Src_Idx  : Positive;
      begin
         Page_Buf (1) := 16#40#; -- Data prefix
         for Page in 0 .. 7 loop
            --  Set page and column start address (works on SSD1306 & SH1106)
            Glyph.Transport.I2C.I2C_Write
              (Bus     => Bus,
               Address => Self.Address,
               Data    =>
                 (1 => 16#00#,
                  2 => Byte (16#B0# + Page),
                  3 => 16#00#,
                  4 => 16#10#));

            --  Copy 128 bytes for this page
            Src_Idx := Data'First + 1 + Page * 128;
            for Col in 1 .. 128 loop
               Page_Buf (1 + Col) := Data (Src_Idx + Col - 1);
            end loop;

            Glyph.Transport.I2C.I2C_Write
              (Bus     => Bus,
               Address => Self.Address,
               Data    => Page_Buf);
         end loop;
      end;
   end Flush;

end Glyph.Controllers.SSD1306;
