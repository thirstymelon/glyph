package body Glyph is

   procedure Initialize is
   begin
      null;
   end Initialize;

   procedure Shutdown is
   begin
      null;
   end Shutdown;

   function Version return String is
   begin
      return Glyph.Current_Version;
   end Version;

end Glyph;
