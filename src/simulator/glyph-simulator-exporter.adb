with Ada.Streams.Stream_IO;
with Interfaces;
with GNAT.OS_Lib;
with Ada.Strings.Fixed;

package body Glyph.Simulator.Exporter is

   use Interfaces;
   use type Glyph.Colors.Monochrome;

   procedure Write_U16
     (Stream : Ada.Streams.Stream_IO.Stream_Access; Value : Unsigned_16) is
   begin
      Unsigned_8'Write (Stream, Unsigned_8 (Value and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 8) and 16#FF#));
   end Write_U16;

   procedure Write_U32
     (Stream : Ada.Streams.Stream_IO.Stream_Access; Value : Unsigned_32) is
   begin
      Unsigned_8'Write (Stream, Unsigned_8 (Value and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 8) and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 16) and 16#FF#));
      Unsigned_8'Write (Stream, Unsigned_8 (Shift_Right (Value, 24) and 16#FF#));
   end Write_U32;

   procedure Write_I32
     (Stream : Ada.Streams.Stream_IO.Stream_Access; Value : Integer_32) is
   begin
      Write_U32 (Stream, Unsigned_32'Mod (Value));
   end Write_I32;

   --  Generic core BMP writer
   generic
      with function Read_Pixel (X, Y : Natural) return Boolean;
   procedure Generic_Export_BMP
     (Src_Width  : Positive;
      Src_Height : Positive;
      File_Path  : String;
      Scale      : Positive;
      FG_Color   : Glyph.Colors.RGB888;
      BG_Color   : Glyph.Colors.RGB888);

   procedure Generic_Export_BMP
     (Src_Width  : Positive;
      Src_Height : Positive;
      File_Path  : String;
      Scale      : Positive;
      FG_Color   : Glyph.Colors.RGB888;
      BG_Color   : Glyph.Colors.RGB888)
   is
      use Ada.Streams.Stream_IO;

      File       : File_Type;
      Stream     : Stream_Access;
      Out_Width  : constant Positive := Src_Width * Scale;
      Out_Height : constant Positive := Src_Height * Scale;
      Row_Bytes  : constant Natural := Out_Width * 3;
      Padding    : constant Natural := (4 - (Row_Bytes mod 4)) mod 4;
      Image_Size : constant Unsigned_32 :=
        Unsigned_32 ((Row_Bytes + Padding) * Out_Height);
      File_Size  : constant Unsigned_32 := 54 + Image_Size;

      Pixel_On   : Boolean;
      Red, Green, Blue : Unsigned_8;
   begin
      Create (File, Out_File, File_Path);
      Stream := Ada.Streams.Stream_IO.Stream (File);

      --  1. BITMAPFILEHEADER (14 bytes)
      Character'Write (Stream, 'B');
      Character'Write (Stream, 'M');
      Write_U32 (Stream, File_Size);
      Write_U16 (Stream, 0);  --  Reserved 1
      Write_U16 (Stream, 0);  --  Reserved 2
      Write_U32 (Stream, 54); --  Offset to pixel data

      --  2. BITMAPINFOHEADER (40 bytes)
      Write_U32 (Stream, 40);                     --  Header size
      Write_I32 (Stream, Integer_32 (Out_Width));  --  Width
      Write_I32 (Stream, -Integer_32 (Out_Height)); --  Height (negative = top-down)
      Write_U16 (Stream, 1);                      --  Planes
      Write_U16 (Stream, 24);                     --  24-bit RGB
      Write_U32 (Stream, 0);                      --  Compression: BI_RGB (none)
      Write_U32 (Stream, Image_Size);             --  Image data size
      Write_I32 (Stream, 2835);                   --  72 DPI X
      Write_I32 (Stream, 2835);                   --  72 DPI Y
      Write_U32 (Stream, 0);                      --  Colors used
      Write_U32 (Stream, 0);                      --  Important colors

      --  3. Pixel Data (24-bit BGR, Top-Down)
      for Y in 0 .. Src_Height - 1 loop
         for SY in 1 .. Scale loop
            for X in 0 .. Src_Width - 1 loop
               Pixel_On := Read_Pixel (X, Y);

               if Pixel_On then
                  Red   := Unsigned_8 (FG_Color.Red);
                  Green := Unsigned_8 (FG_Color.Green);
                  Blue  := Unsigned_8 (FG_Color.Blue);
               else
                  Red   := Unsigned_8 (BG_Color.Red);
                  Green := Unsigned_8 (BG_Color.Green);
                  Blue  := Unsigned_8 (BG_Color.Blue);
               end if;

               for SX in 1 .. Scale loop
                  --  Windows BMP stores pixels in BGR order
                  Unsigned_8'Write (Stream, Blue);
                  Unsigned_8'Write (Stream, Green);
                  Unsigned_8'Write (Stream, Red);
               end loop;
            end loop;

            --  Row alignment padding to 4-byte multiple
            for P in 1 .. Padding loop
               Unsigned_8'Write (Stream, 0);
            end loop;
         end loop;
      end loop;

      Close (File);
   end Generic_Export_BMP;

   --  Generic core PPM writer
   generic
      with function Read_Pixel (X, Y : Natural) return Boolean;
   procedure Generic_Export_PPM
     (Src_Width  : Positive;
      Src_Height : Positive;
      File_Path  : String;
      Scale      : Positive;
      FG_Color   : Glyph.Colors.RGB888;
      BG_Color   : Glyph.Colors.RGB888);

   procedure Generic_Export_PPM
     (Src_Width  : Positive;
      Src_Height : Positive;
      File_Path  : String;
      Scale      : Positive;
      FG_Color   : Glyph.Colors.RGB888;
      BG_Color   : Glyph.Colors.RGB888)
   is
      use Ada.Streams.Stream_IO;

      File       : File_Type;
      Stream     : Stream_Access;
      Out_Width  : constant Positive := Src_Width * Scale;
      Out_Height : constant Positive := Src_Height * Scale;
      Header     : constant String :=
        "P6" & ASCII.LF &
        Positive'Image (Out_Width) (2 .. Positive'Image (Out_Width)'Last) & " " &
        Positive'Image (Out_Height) (2 .. Positive'Image (Out_Height)'Last) & ASCII.LF &
        "255" & ASCII.LF;

      Pixel_On   : Boolean;
      Red, Green, Blue : Unsigned_8;
   begin
      Create (File, Out_File, File_Path);
      Stream := Ada.Streams.Stream_IO.Stream (File);

      --  Write PPM P6 Header
      String'Write (Stream, Header);

      --  Write PPM RGB Pixels
      for Y in 0 .. Src_Height - 1 loop
         for SY in 1 .. Scale loop
            for X in 0 .. Src_Width - 1 loop
               Pixel_On := Read_Pixel (X, Y);

               if Pixel_On then
                  Red   := Unsigned_8 (FG_Color.Red);
                  Green := Unsigned_8 (FG_Color.Green);
                  Blue  := Unsigned_8 (FG_Color.Blue);
               else
                  Red   := Unsigned_8 (BG_Color.Red);
                  Green := Unsigned_8 (BG_Color.Green);
                  Blue  := Unsigned_8 (BG_Color.Blue);
               end if;

               for SX in 1 .. Scale loop
                  Unsigned_8'Write (Stream, Red);
                  Unsigned_8'Write (Stream, Green);
                  Unsigned_8'Write (Stream, Blue);
               end loop;
            end loop;
         end loop;
      end loop;

      Close (File);
   end Generic_Export_PPM;

   procedure Export_BMP
     (Port      : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path : String;
      Scale     : Positive := 4;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark)
   is
      function Port_Pixel (X, Y : Natural) return Boolean is
      begin
         return Port.Get_Pixel (X, Y);
      end Port_Pixel;

      procedure Render_BMP is new Generic_Export_BMP (Port_Pixel);
   begin
      Render_BMP
        (Src_Width  => Glyph.Simulator.I2C.Display_Width,
         Src_Height => Glyph.Simulator.I2C.Display_Height,
         File_Path  => File_Path,
         Scale      => Scale,
         FG_Color   => FG_Color,
         BG_Color   => BG_Color);
   end Export_BMP;

   procedure Export_BMP
     (Canvas    : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path : String;
      Scale     : Positive := 4;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark)
   is
      function Canvas_Pixel (X, Y : Natural) return Boolean is
      begin
         return Canvas.Get_Pixel (X, Y) = Glyph.Colors.On;
      end Canvas_Pixel;

      procedure Render_BMP is new Generic_Export_BMP (Canvas_Pixel);
   begin
      Render_BMP
        (Src_Width  => 128,
         Src_Height => 64,
         File_Path  => File_Path,
         Scale      => Scale,
         FG_Color   => FG_Color,
         BG_Color   => BG_Color);
   end Export_BMP;

   procedure Export_PPM
     (Port      : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path : String;
      Scale     : Positive := 1;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark)
   is
      function Port_Pixel (X, Y : Natural) return Boolean is
      begin
         return Port.Get_Pixel (X, Y);
      end Port_Pixel;

      procedure Render_PPM is new Generic_Export_PPM (Port_Pixel);
   begin
      Render_PPM
        (Src_Width  => Glyph.Simulator.I2C.Display_Width,
         Src_Height => Glyph.Simulator.I2C.Display_Height,
         File_Path  => File_Path,
         Scale      => Scale,
         FG_Color   => FG_Color,
         BG_Color   => BG_Color);
   end Export_PPM;

   procedure Export_PPM
     (Canvas    : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path : String;
      Scale     : Positive := 1;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark)
   is
      function Canvas_Pixel (X, Y : Natural) return Boolean is
      begin
         return Canvas.Get_Pixel (X, Y) = Glyph.Colors.On;
      end Canvas_Pixel;

      procedure Render_PPM is new Generic_Export_PPM (Canvas_Pixel);
   begin
      Render_PPM
        (Src_Width  => 128,
         Src_Height => 64,
         File_Path  => File_Path,
         Scale      => Scale,
         FG_Color   => FG_Color,
         BG_Color   => BG_Color);
   end Export_PPM;

   function Find_FFmpeg return String is
      use type GNAT.OS_Lib.String_Access;
      Found : GNAT.OS_Lib.String_Access :=
        GNAT.OS_Lib.Locate_Exec_On_Path ("ffmpeg");
   begin
      if Found /= null then
         declare
            Path : constant String := Found.all;
         begin
            GNAT.OS_Lib.Free (Found);
            return Path;
         end;
      elsif GNAT.OS_Lib.Is_Regular_File ("/opt/homebrew/bin/ffmpeg") then
         return "/opt/homebrew/bin/ffmpeg";
      elsif GNAT.OS_Lib.Is_Regular_File ("/usr/local/bin/ffmpeg") then
         return "/usr/local/bin/ffmpeg";
      elsif GNAT.OS_Lib.Is_Regular_File ("/usr/bin/ffmpeg") then
         return "/usr/bin/ffmpeg";
      else
         return "ffmpeg";
      end if;
   end Find_FFmpeg;

   procedure Export_GIF
     (Port         : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 2;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark)
   is
      Tmp_BMP : constant String := File_Path & ".tmp.bmp";
      Success : Boolean;
   begin
      Export_BMP
        (Port      => Port,
         File_Path => Tmp_BMP,
         Scale     => Scale,
         FG_Color  => FG_Color,
         BG_Color  => BG_Color);

      declare
         Dur_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (Duration_Sec), Ada.Strings.Both);
         Args : GNAT.OS_Lib.Argument_List :=
           [new String'("-y"),
            new String'("-loop"),
            new String'("1"),
            new String'("-t"),
            new String'(Dur_Str),
            new String'("-i"),
            new String'(Tmp_BMP),
            new String'("-vf"),
            new String'("split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"),
            new String'(File_Path)];
      begin
         GNAT.OS_Lib.Spawn (Find_FFmpeg, Args, Success);
         for I in Args'Range loop
            GNAT.OS_Lib.Free (Args (I));
         end loop;
      end;

      GNAT.OS_Lib.Delete_File (Tmp_BMP, Success);
   end Export_GIF;

   procedure Export_GIF
     (Canvas       : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 2;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark)
   is
      Tmp_BMP : constant String := File_Path & ".tmp.bmp";
      Success : Boolean;
   begin
      Export_BMP
        (Canvas    => Canvas,
         File_Path => Tmp_BMP,
         Scale     => Scale,
         FG_Color  => FG_Color,
         BG_Color  => BG_Color);

      declare
         Dur_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (Duration_Sec), Ada.Strings.Both);
         Args : GNAT.OS_Lib.Argument_List :=
           [new String'("-y"),
            new String'("-loop"),
            new String'("1"),
            new String'("-t"),
            new String'(Dur_Str),
            new String'("-i"),
            new String'(Tmp_BMP),
            new String'("-vf"),
            new String'("split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"),
            new String'(File_Path)];
      begin
         GNAT.OS_Lib.Spawn (Find_FFmpeg, Args, Success);
         for I in Args'Range loop
            GNAT.OS_Lib.Free (Args (I));
         end loop;
      end;

      GNAT.OS_Lib.Delete_File (Tmp_BMP, Success);
   end Export_GIF;

   procedure Export_Video
     (Port         : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 3;
      FPS          : Positive := 30;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark)
   is
      Tmp_BMP : constant String := File_Path & ".tmp.bmp";
      Success : Boolean;
   begin
      Export_BMP
        (Port      => Port,
         File_Path => Tmp_BMP,
         Scale     => Scale,
         FG_Color  => FG_Color,
         BG_Color  => BG_Color);

      declare
         Dur_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (Duration_Sec), Ada.Strings.Both);
         FPS_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (FPS), Ada.Strings.Both);
         Args : GNAT.OS_Lib.Argument_List :=
           [new String'("-y"),
            new String'("-loop"),
            new String'("1"),
            new String'("-t"),
            new String'(Dur_Str),
            new String'("-framerate"),
            new String'(FPS_Str),
            new String'("-i"),
            new String'(Tmp_BMP),
            new String'("-c:v"),
            new String'("libx264"),
            new String'("-pix_fmt"),
            new String'("yuv420p"),
            new String'("-vf"),
            new String'("pad=ceil(iw/2)*2:ceil(ih/2)*2"),
            new String'(File_Path)];
      begin
         GNAT.OS_Lib.Spawn (Find_FFmpeg, Args, Success);
         for I in Args'Range loop
            GNAT.OS_Lib.Free (Args (I));
         end loop;
      end;

      GNAT.OS_Lib.Delete_File (Tmp_BMP, Success);
   end Export_Video;

   procedure Export_Video
     (Canvas       : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 3;
      FPS          : Positive := 30;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark)
   is
      Tmp_BMP : constant String := File_Path & ".tmp.bmp";
      Success : Boolean;
   begin
      Export_BMP
        (Canvas    => Canvas,
         File_Path => Tmp_BMP,
         Scale     => Scale,
         FG_Color  => FG_Color,
         BG_Color  => BG_Color);

      declare
         Dur_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (Duration_Sec), Ada.Strings.Both);
         FPS_Str : constant String :=
           Ada.Strings.Fixed.Trim (Positive'Image (FPS), Ada.Strings.Both);
         Args : GNAT.OS_Lib.Argument_List :=
           [new String'("-y"),
            new String'("-loop"),
            new String'("1"),
            new String'("-t"),
            new String'(Dur_Str),
            new String'("-framerate"),
            new String'(FPS_Str),
            new String'("-i"),
            new String'(Tmp_BMP),
            new String'("-c:v"),
            new String'("libx264"),
            new String'("-pix_fmt"),
            new String'("yuv420p"),
            new String'("-vf"),
            new String'("pad=ceil(iw/2)*2:ceil(ih/2)*2"),
            new String'(File_Path)];
      begin
         GNAT.OS_Lib.Spawn (Find_FFmpeg, Args, Success);
         for I in Args'Range loop
            GNAT.OS_Lib.Free (Args (I));
         end loop;
      end;

      GNAT.OS_Lib.Delete_File (Tmp_BMP, Success);
   end Export_Video;

end Glyph.Simulator.Exporter;
