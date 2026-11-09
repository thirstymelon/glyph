with Glyph.Types;
with Glyph.Colors;
with Glyph.Transport;
with Glyph.Fonts;

generic
   Width : Positive;
   Height : Positive;
package Glyph.Canvas.Generic_Mono with
  SPARK_Mode => On
is

   subtype X_Range is Natural range 0 .. Width - 1;
   subtype Y_Range is Natural range 0 .. Height - 1;

   Total_Pages : constant Positive := (Height + 7) / 8;
   Stream_Size : constant Positive := Width * Total_Pages;

   type Framebuffer_T is array (X_Range, Y_Range) of Glyph.Colors.Monochrome
   with Pack;

   type Instance is tagged limited private;

   --  Default font configuration for this canvas
   procedure Set_Default_Font (Self : in out Instance; F : Glyph.Fonts.Font);
   function Get_Default_Font (Self : Instance) return Glyph.Fonts.Font;

   procedure Clear (Self : in out Instance);

   procedure Paint_Pixel
     (Self  : in out Instance;
      X     : Integer;
      Y     : Integer;
      Color : Glyph.Colors.Monochrome := Glyph.Colors.On);

   procedure Paint_Line
     (Self : in out Instance; X1, Y1 : Integer; X2, Y2 : Integer);

   procedure Paint_Line (Self : in out Instance; Line : Glyph.Types.Line);

   procedure Paint_Rectangle
     (Self : in out Instance; X, Y : Integer; Width, Height : Integer);

   procedure Paint_Rectangle
     (Self : in out Instance; Rect : Glyph.Types.Rectangle);

   procedure Paint_Filled_Rectangle
     (Self : in out Instance; X, Y : Integer; Width, Height : Integer);

   procedure Paint_Filled_Rectangle
     (Self : in out Instance; Rect : Glyph.Types.Rectangle);

   procedure Paint_Circle
     (Self               : in out Instance;
      Center_X, Center_Y : Integer;
      Radius             : Integer;
      Start_Angle        : Integer := 0;
      End_Angle          : Integer := 360);

   procedure Paint_Circle
     (Self : in out Instance; Circle : Glyph.Types.Circle);

   procedure Paint_Filled_Circle
     (Self               : in out Instance;
      Center_X, Center_Y : Integer;
      Radius             : Integer;
      Start_Angle        : Integer := 0;
      End_Angle          : Integer := 360);

   procedure Paint_Filled_Circle
     (Self : in out Instance; Circle : Glyph.Types.Circle);

   procedure Paint_Arc
     (Self               : in out Instance;
      Center_X, Center_Y : Integer;
      Radius             : Integer;
      Start_Angle        : Integer := 0;
      End_Angle          : Integer := 360);

   procedure Paint_Half_Circle
     (Self               : in out Instance;
      Center_X, Center_Y : Integer;
      Radius             : Integer;
      Side               : Glyph.Types.Hemisphere := Glyph.Types.Top);

   procedure Paint_Filled_Half_Circle
     (Self               : in out Instance;
      Center_X, Center_Y : Integer;
      Radius             : Integer;
      Side               : Glyph.Types.Hemisphere := Glyph.Types.Top);

   procedure Paint_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer);

   procedure Paint_Triangle
     (Self : in out Instance; Triangle : Glyph.Types.Triangle);

   procedure Paint_Filled_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer);

   procedure Paint_Filled_Triangle
     (Self : in out Instance; Triangle : Glyph.Types.Triangle);

   --  Text using canvas default font (Font is optional!)
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Text     : String;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

   --  Text with specific one-off font override
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Text     : String;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

   --  Character using canvas default font (Font is optional!)
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Char     : Character;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

   --  Character with specific one-off font override
   procedure Paint_Text
     (Self     : in out Instance;
      X, Y     : Integer;
      Char     : Character;
      Font     : Glyph.Fonts.Font;
      Scale    : Positive := 1;
      Color    : Glyph.Colors.Monochrome := Glyph.Colors.On;
      Bg_Color : Glyph.Colors.Monochrome := Glyph.Colors.Off;
      Opaque   : Boolean := False);

   function Get_Pixel
     (Self : Instance; X : Natural; Y : Natural)
      return Glyph.Colors.Monochrome with
     Pre => X in X_Range and Y in Y_Range;

   procedure Fill_Page_Stream
     (Self        : Instance;
      Data        : out Glyph.Transport.Byte_Array;
      Prefix_Byte : Glyph.Transport.Byte := 16#40#;
      Has_Prefix  : Boolean := True) with
     Pre => (if Has_Prefix then Data'Length >= Stream_Size + 1
             else Data'Length >= Stream_Size);

   procedure Fill_Page_Stream_Window
     (Self        : Instance;
      Col_Start   : X_Range;
      Col_End     : X_Range;
      Page_Start  : Natural;
      Page_End    : Natural;
      Data        : out Glyph.Transport.Byte_Array;
      Prefix_Byte : Glyph.Transport.Byte := 16#40#;
      Has_Prefix  : Boolean := True) with
     Pre => Col_Start <= Col_End
            and then Page_Start <= Page_End
            and then Page_End < Total_Pages;


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
      Buffer       : Framebuffer_T    := (others => (others => Glyph.Colors.Off));
      Damage       : Damage_Bounds    := (Has_Damage => False, others => 0);
      Default_Font : Glyph.Fonts.Font := Glyph.Fonts.Font_5x7;
   end record;


   procedure Mark_Dirty (Self : in out Instance; Rect : Glyph.Types.Rectangle);

   procedure Mark_All_Dirty (Self : in out Instance);

end Glyph.Canvas.Generic_Mono;
