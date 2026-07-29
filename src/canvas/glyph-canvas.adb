package body Glyph.Canvas is

   procedure Create
     (Self : in out Canvas; Display : not null access Glyph.Display.Display) is
   begin
      if Self.Display /= null then
         raise Program_Error with "Canvas has already been created.";
      end if;

      Self.Display := Display;
   end Create;

   procedure Clear (Self : in out Canvas) is
   begin
      null;
   end Clear;

   procedure Flush (Self : in out Canvas) is
   begin
      if Self.Display = null then
         raise Program_Error with "Canvas has not been created.";
      end if;

      if not Glyph.Display.Is_Initialized (Self.Display.all) then
         raise Program_Error with "Display has not been initialized.";
      end if;

      Glyph.Display.Flush (Self.Display.all);
   end Flush;

end Glyph.Canvas;
