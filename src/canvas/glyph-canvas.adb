package body Glyph.Canvas is

   procedure Attach
     (Self    : in out Canvas;
      Display : not null access Glyph.Display.Display'Class) is
   begin
      Self.Display := Display;
   end Attach;

   procedure Clear (Self : in out Canvas) is
   begin
      null;
   end Clear;

   procedure Flush (Self : in out Canvas) is
   begin
      if Self.Display /= null then
         Glyph.Display.Flush (Self.Display.all);
      end if;
   end Flush;

end Glyph.Canvas;
