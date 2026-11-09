with HAL.I2C;
with Glyph.Canvas.C128x64_Mono;
with Glyph.Controllers.SSD1306;
with Glyph.Fonts;
with Glyph.Colors;

package Glyph.Display.SSD1306 with
  SPARK_Mode => Off
is

   type Transport_Mode is (Framebuffer, Direct_Stream);

   subtype Canvas_T is Glyph.Canvas.C128x64_Mono.Instance;

   type Any_I2C_Port is access all HAL.I2C.I2C_Port'Class;

   type Display_T is tagged limited record
      Mode         : Transport_Mode := Framebuffer;
      Controller   : Glyph.Controllers.SSD1306.Controller;
      Bus          : Any_I2C_Port := null;
      Default_Font : Glyph.Fonts.Font := Glyph.Fonts.Font_5x7;
      Canvas       : Canvas_T;
   end record;

   function Create return Display_T;
   function Create (Mode : Transport_Mode) return Display_T;

   procedure Init
     (Self : in out Display_T; Bus : access HAL.I2C.I2C_Port'Class);

   --  I2C Address configuration (defaults to 16#3C#)
   procedure Set_Address (Self : in out Display_T; Address : HAL.I2C.I2C_Address);
   function Get_Address (Self : Display_T) return HAL.I2C.I2C_Address;

   --  Default font configuration
   procedure Set_Default_Font (Self : in out Display_T; F : Glyph.Fonts.Font);
   function Get_Default_Font (Self : Display_T) return Glyph.Fonts.Font;

   --  Flush display changes to SSD1306 hardware
   procedure Render (Self : in out Display_T; Force : Boolean := False);

   --  Unified Painting APIs across modes
   procedure Clear (Self : in out Display_T);

   procedure Paint_Pixel
     (Self  : in out Display_T;
      X     : Integer;
      Y     : Integer;
      Color : Glyph.Colors.Monochrome := Glyph.Colors.On);

   procedure Paint_Line
     (Self : in out Display_T;
      X1, Y1 : Integer;
      X2, Y2 : Integer);

   procedure Paint_Rectangle
     (Self   : in out Display_T;
      X, Y   : Integer;
      Width  : Integer;
      Height : Integer);

   procedure Paint_Filled_Rectangle
     (Self   : in out Display_T;
      X, Y   : Integer;
      Width  : Integer;
      Height : Integer);

   procedure Paint_Circle
     (Self     : in out Display_T;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer);

   procedure Paint_Filled_Circle
     (Self     : in out Display_T;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer);

   --  Text with default font
   procedure Paint_Text
     (Self     : in out Display_T;
      X, Y     : Integer;
      Text     : String;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

   --  Text with specific one-off font override
   procedure Paint_Text
     (Self     : in out Display_T;
      X, Y     : Integer;
      Text     : String;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

   --  Character with default font
   procedure Paint_Text
     (Self     : in out Display_T;
      X, Y     : Integer;
      Char     : Character;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

   --  Character with specific one-off font override
   procedure Paint_Text
     (Self     : in out Display_T;
      X, Y     : Integer;
      Char     : Character;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

end Glyph.Display.SSD1306;
