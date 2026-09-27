generic
   type Canvas_Type is limited private;
   type Controller_Type is limited private;
   type Bus_Type (<>) is limited private;
   with procedure Controller_Init
     (Controller : in out Controller_Type;
      Bus        : in out Bus_Type);
   with procedure Render_Frame
     (Canvas     : in Canvas_Type;
      Controller : in out Controller_Type;
      Bus        : in out Bus_Type);
package Glyph.Display.Generic_Display is

   type Display_T is tagged limited record
      Canvas     : Canvas_Type;
      Controller : Controller_Type;
      Bus        : access Bus_Type := null;
   end record;

   procedure Init
     (Self : in out Display_T;
      Bus  : access Bus_Type);

   procedure Render (Self : in out Display_T);

end Glyph.Display.Generic_Display;
