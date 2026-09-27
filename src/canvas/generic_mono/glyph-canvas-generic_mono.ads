with Glyph.Types;
with Glyph.Colors;
with Glyph.Transport;

generic
   Width  : Positive;
   Height : Positive;
package Glyph.Canvas.Generic_Mono is

   subtype X_Range is Natural range 0 .. Width - 1;
   subtype Y_Range is Natural range 0 .. Height - 1;

   Total_Pages : constant Positive := (Height + 7) / 8;
   Stream_Size : constant Positive := Width * Total_Pages;

   type Framebuffer_T is
     array (X_Range, Y_Range) of Glyph.Colors.Monochrome
   with Pack;

   type Instance is tagged limited record
      Buffer : Framebuffer_T := (others => (others => Glyph.Colors.Off));
   end record;

   procedure Clear (Self : in out Instance);

   procedure Paint_Pixel
     (Self : in out Instance;
      X    : Integer;
      Y    : Integer);

   procedure Paint_Line
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer);

   procedure Paint_Line
     (Self : in out Instance;
      Line : Glyph.Types.Line);

   procedure Paint_Rectangle
     (Self          : in out Instance;
      X, Y          : Integer;
      Width, Height : Integer);

   procedure Paint_Rectangle
     (Self : in out Instance;
      Rect : Glyph.Types.Rectangle);

   procedure Paint_Filled_Rectangle
     (Self          : in out Instance;
      X, Y          : Integer;
      Width, Height : Integer);

   procedure Paint_Filled_Rectangle
     (Self : in out Instance;
      Rect : Glyph.Types.Rectangle);

   procedure Paint_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Start_Angle       : Integer := 0;
      End_Angle         : Integer := 360);

   procedure Paint_Circle
     (Self   : in out Instance;
      Circle : Glyph.Types.Circle);

   procedure Paint_Filled_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Start_Angle       : Integer := 0;
      End_Angle         : Integer := 360);

   procedure Paint_Filled_Circle
     (Self   : in out Instance;
      Circle : Glyph.Types.Circle);

   procedure Paint_Arc
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Start_Angle       : Integer := 0;
      End_Angle         : Integer := 360);

   procedure Paint_Half_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Side              : Glyph.Types.Hemisphere := Glyph.Types.Top);

   procedure Paint_Filled_Half_Circle
     (Self              : in out Instance;
      Center_X, Center_Y : Integer;
      Radius            : Integer;
      Side              : Glyph.Types.Hemisphere := Glyph.Types.Top);

   procedure Paint_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer);

   procedure Paint_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle);

   procedure Paint_Filled_Triangle
     (Self   : in out Instance;
      X1, Y1 : Integer;
      X2, Y2 : Integer;
      X3, Y3 : Integer);

   procedure Paint_Filled_Triangle
     (Self     : in out Instance;
      Triangle : Glyph.Types.Triangle);

   function Get_Pixel
     (Self : Instance; X : Natural; Y : Natural)
      return Glyph.Colors.Monochrome;

   procedure Fill_Page_Stream
     (Self        : Instance;
      Data        : out Glyph.Transport.Byte_Array;
      Prefix_Byte : Glyph.Transport.Byte := 16#40#;
      Has_Prefix  : Boolean := True);

end Glyph.Canvas.Generic_Mono;
