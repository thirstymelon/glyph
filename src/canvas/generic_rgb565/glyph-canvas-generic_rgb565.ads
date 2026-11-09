with Glyph.Types;
with Glyph.Colors;
with Glyph.Transport;
with Glyph.Fonts;

generic
   Width  : Positive;
   Height : Positive;
package Glyph.Canvas.Generic_RGB565 with
  SPARK_Mode => Off
is

   subtype X_Range is Natural range 0 .. Width - 1;
   subtype Y_Range is Natural range 0 .. Height - 1;

   Total_Pixels : constant Positive := Width * Height;
   Stream_Bytes : constant Positive := Total_Pixels * 2;

   type Framebuffer_T is array (X_Range, Y_Range) of Glyph.Colors.RGB565;

   type Instance is tagged limited private;

   --  Default font configuration for this canvas
   procedure Set_Default_Font (Self : in out Instance; F : Glyph.Fonts.Font);
   function Get_Default_Font (Self : Instance) return Glyph.Fonts.Font;

   procedure Clear
     (Self  : in out Instance;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.Black);

   procedure Paint_Pixel
     (Self  : in out Instance;
      X     : Integer;
      Y     : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Line
     (Self  : in out Instance;
      X1    : Integer;
      Y1    : Integer;
      X2    : Integer;
      Y2    : Integer;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Line
     (Self  : in out Instance;
      Line  : Glyph.Types.Line;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Rectangle
     (Self   : in out Instance;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Rectangle
     (Self  : in out Instance;
      Rect  : Glyph.Types.Rectangle;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Rectangle
     (Self   : in out Instance;
      X      : Integer;
      Y      : Integer;
      Width  : Integer;
      Height : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Rectangle
     (Self  : in out Instance;
      Rect  : Glyph.Types.Rectangle;
      Color : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Circle
     (Self        : in out Instance;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Circle
     (Self   : in out Instance;
      Circle : Glyph.Types.Circle;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Circle
     (Self        : in out Instance;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Circle
     (Self   : in out Instance;
      Circle : Glyph.Types.Circle;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Arc
     (Self        : in out Instance;
      Center_X    : Integer;
      Center_Y    : Integer;
      Radius      : Integer;
      Start_Angle : Integer := 0;
      End_Angle   : Integer := 360;
      Color       : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Half_Circle
     (Self     : in out Instance;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer;
      Side     : Glyph.Types.Hemisphere := Glyph.Types.Top;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Half_Circle
     (Self     : in out Instance;
      Center_X : Integer;
      Center_Y : Integer;
      Radius   : Integer;
      Side     : Glyph.Types.Hemisphere := Glyph.Types.Top;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer;
      Color  : Glyph.Colors.RGB565 := Glyph.Colors.White);

   procedure Paint_Filled_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White);

   --  Text using canvas default font (Font is optional!)
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Text     : String;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

   --  Text with specific one-off font override
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Text     : String;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

   --  Character using canvas default font (Font is optional!)
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Char     : Character;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

   --  Character with specific one-off font override
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Char     : Character;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.RGB565 := Glyph.Colors.White;
      Bg_Color : Glyph.Colors.RGB565 := Glyph.Colors.Black;
      Opaque   : Boolean := False);

   function Get_Pixel
     (Self : Instance; X : Natural; Y : Natural) return Glyph.Colors.RGB565 with
     Pre => X in X_Range and Y in Y_Range;

   --  Export window stream (Big-Endian RGB565 byte pairs)
   procedure Export_Window_Stream
     (Self      : Instance;
      Col_Start : X_Range;
      Col_End   : X_Range;
      Row_Start : Y_Range;
      Row_End   : Y_Range;
      Data      : out Glyph.Transport.Byte_Array);


   --  Damage tracking inspection and management
   function Has_Damage (Self : Instance) return Boolean;
   function Get_Damage (Self : Instance) return Glyph.Types.Rectangle;
   procedure Reset_Damage (Self : in out Instance);

private

   type Damage_Bounds is record
      Has_Damage : Boolean := False;
      Min_X      : X_Range := 0;
      Max_X      : X_Range := 0;
      Min_Y      : Y_Range := 0;
      Max_Y      : Y_Range := 0;
   end record;

   type Instance is tagged limited record
      Buffer       : Framebuffer_T    := (others => (others => Glyph.Colors.Black));
      Damage       : Damage_Bounds    := (Has_Damage => False, others => 0);
      Default_Font : Glyph.Fonts.Font := Glyph.Fonts.Font_5x7;
   end record;

   procedure Mark_Dirty (Self : in out Instance; Rect : Glyph.Types.Rectangle);

   procedure Mark_All_Dirty (Self : in out Instance);

end Glyph.Canvas.Generic_RGB565;
