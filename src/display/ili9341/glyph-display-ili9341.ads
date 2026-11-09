with HAL.SPI;
with HAL.GPIO;
with Glyph.Canvas.Generic_RGB565;
with Glyph.Controllers.ILI9341;
with Glyph.Fonts;
with Glyph.Colors;
with Glyph.Transport;
with Glyph.Transport.SPI;

package Glyph.Display.ILI9341 with
  SPARK_Mode => Off
is

   type Transport_Mode is (Framebuffer, Tile_Stream, Direct_Stream);

   package Tile_Canvas_Pkg is new
     Glyph.Canvas.Generic_RGB565 (Width => 240, Height => 32);

   type Any_SPI_Port is access all HAL.SPI.SPI_Port'Class;
   subtype Any_GPIO_Point is Glyph.Transport.SPI.Any_GPIO_Point;

   type Display_T is tagged limited record
      Mode          : Transport_Mode := Tile_Stream;
      Controller    : Glyph.Controllers.ILI9341.Controller;
      SPI           : Any_SPI_Port   := null;
      CS            : Any_GPIO_Point := null;
      DC            : Any_GPIO_Point := null;
      Reset         : Any_GPIO_Point := null;
      Default_Font  : Glyph.Fonts.Font := Glyph.Fonts.Font_5x7;
      Band_Offset_Y : Integer := 0;
      Tile_Canvas   : Tile_Canvas_Pkg.Instance;
   end record;

   function Create return Display_T;
   function Create (Mode : Transport_Mode) return Display_T;

   procedure Init
     (Self  : in out Display_T;
      SPI   : access HAL.SPI.SPI_Port'Class;
      DC    : access HAL.GPIO.GPIO_Point'Class;
      CS    : access HAL.GPIO.GPIO_Point'Class := null;
      Reset : access HAL.GPIO.GPIO_Point'Class := null);

   procedure Set_Orientation
     (Self        : in out Display_T;
      Orientation : Glyph.Controllers.ILI9341.Orientation_Type);

   function Current_Width (Self : Display_T) return Positive is
     (Self.Controller.Current_Width);

   function Current_Height (Self : Display_T) return Positive is
     (Self.Controller.Current_Height);

   --  Default font configuration
   procedure Set_Default_Font (Self : in out Display_T; F : Glyph.Fonts.Font);
   function Get_Default_Font (Self : Display_T) return Glyph.Fonts.Font;

   --  Flush canvas changes to ILI9341 hardware
   procedure Render (Self : in out Display_T; Force : Boolean := False);

   --  Transparent scene rendering: user draws in natural (0..319) screen coordinates;
   --  all tile banding and coordinate translations are handled internally with zero user math.
   procedure Render_Scene
     (Self : in out Display_T;
      Draw : not null access procedure (Disp : in out Display_T));

   --  Explicit offset scene rendering (retained for custom band math or manual offsetting)
   procedure Render_Scene
     (Self : in out Display_T;
      Draw : not null access procedure (Disp : in out Display_T; Offset_Y : Integer));

   --  Zero-trampoline generic scene rendering (fully compatible with No_Implicit_Dynamic_Code)
   generic
      with procedure Draw (Disp : in out Display_T);
   procedure Generic_Render_Scene (Self : in out Display_T);

   --  Unified Painting APIs across all modes
   procedure Clear
     (Self  : in out Display_T;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.Black);

   procedure Paint_Pixel
     (Self  : in out Display_T;
      X     : Integer;
      Y     : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Line
     (Self  : in out Display_T;
      X1    : Integer;
      Y1    : Integer;
      X2    : Integer;
      Y2    : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Rectangle
     (Self   : in out Display_T;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Rectangle
     (Self   : in out Display_T;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Circle
     (Self        : in out Display_T;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Circle
     (Self        : in out Display_T;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Triangle
     (Self   : in out Display_T;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Triangle
     (Self   : in out Display_T;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   --  Text with default font (Font is optional!)
   procedure Paint_Text
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
      Text     : String;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

   --  Text with specific one-off font override
   procedure Paint_Text
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
      Text     : String;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

   --  Character with default font (Font is optional!)
   procedure Paint_Text
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
      Char     : Character;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

   --  Character with specific one-off font override
   procedure Paint_Text
     (Self     : in out Display_T;
      X        : Integer;
      Y        : Integer;
      Char     : Character;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

end Glyph.Display.ILI9341;
