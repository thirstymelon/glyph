with HAL.I2C;
with Glyph.Canvas.C128x64_Mono;
with Glyph.Controllers.SSD1306;
with Glyph.Fonts;
with Glyph.Transport;

package Glyph.Display is

   type Display_Type is (SSD1306_128x64_I2C);

   type Transport_Mode is (Framebuffer, GDDRAM_Stream);

   subtype Canvas_T is Glyph.Canvas.C128x64_Mono.Instance;

   type Display_T is tagged limited record
      Canvas     : Canvas_T;
      Controller : Glyph.Controllers.SSD1306.Controller;
      Bus        : access HAL.I2C.I2C_Port'Class := null;
      Mode       : Transport_Mode := Framebuffer;
   end record;

   function Get_Display (Kind : Display_Type) return Display_T;

   procedure Set_Transport_Mode
     (Self : in out Display_T; Mode : Transport_Mode);

   function Get_Transport_Mode (Self : Display_T) return Transport_Mode;

   procedure Init
     (Self : in out Display_T; Bus : access HAL.I2C.I2C_Port'Class);

   procedure Render (Self : in out Display_T);

   --  Direct GDDRAM Streaming APIs (Zero-framebuffer memory)
   procedure Stream_Clear (Self : in out Display_T);

   procedure Stream_Text
     (Self   : in out Display_T;
      Page   : Natural;
      Column : Natural;
      Text   : String;
      Font   : Glyph.Fonts.Font := Glyph.Fonts.Font_5x7);

   procedure Stream_Data
     (Self       : in out Display_T;
      Col_Start  : Natural;
      Col_End    : Natural;
      Page_Start : Natural;
      Page_End   : Natural;
      Data       : Glyph.Transport.Byte_Array);

end Glyph.Display;
