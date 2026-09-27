with HAL.I2C;
with Glyph.Canvas.C128x64_Mono;
with Glyph.Controllers.SSD1306;

package Glyph.Display is

   type Display_Type is (SSD1306_128x64_I2C);

   subtype Canvas_T is Glyph.Canvas.C128x64_Mono.Instance;

   type Display_T is tagged limited record
      Canvas     : Canvas_T;
      Controller : Glyph.Controllers.SSD1306.Controller;
      Bus        : access HAL.I2C.I2C_Port'Class := null;
   end record;

   function Get_Display (Kind : Display_Type) return Display_T;

   procedure Init
     (Self : in out Display_T; Bus : access HAL.I2C.I2C_Port'Class);

   procedure Render (Self : in out Display_T);

end Glyph.Display;
