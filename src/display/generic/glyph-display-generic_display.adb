package body Glyph.Display.Generic_Display is

   procedure Init
     (Self : in out Display_T;
      Bus  : access Bus_Type) is
   begin
      Self.Bus := Bus;
      if Bus /= null then
         Controller_Init (Self.Controller, Bus.all);
      end if;
   end Init;

   procedure Render (Self : in out Display_T) is
   begin
      if Self.Bus /= null then
         Render_Frame (Self.Canvas, Self.Controller, Self.Bus.all);
      end if;
   end Render;

end Glyph.Display.Generic_Display;
