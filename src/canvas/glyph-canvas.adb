package body Glyph.Canvas is

   procedure Create
     (Self : in out Canvas; Display : not null access Glyph.Display.Display) is
   begin
      Self.Display := Display;
   end Attach;

   procedure Clear (Self : in out Canvas) is
   begin
      null;
   end Clear;

   procedure Flush (Self : in out Canvas) is
   begin
      if Self.Display = null then
         raise Program_Error with "Canvas has not been created.";
      end if;

      Glyph.Display.Flush (Self.Display.all);
   end Flush;

end Glyph.Canvas;
