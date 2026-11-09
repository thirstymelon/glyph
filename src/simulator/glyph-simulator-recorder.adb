with Ada.Text_IO;
with Ada.Strings.Fixed;
with GNAT.OS_Lib;
with Glyph.Transport;

package body Glyph.Simulator.Recorder is

   function Format_Frame_Index (Idx : Positive) return String is
      Img : constant String :=
        Ada.Strings.Fixed.Trim (Positive'Image (Idx), Ada.Strings.Both);
      Padded : String (1 .. 5) := "00000";
   begin
      Padded (6 - Img'Length .. 5) := Img;
      return Padded;
   end Format_Frame_Index;

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

   procedure Start
     (This         : in out Recorder_T;
      Session_Name : String := "session")
   is
   begin
      This.Active := True;
      This.Frame_Index := 0;
      This.Session_Len := Natural'Min (Session_Name'Length, This.Session_Dir'Length);
      This.Session_Dir (1 .. This.Session_Len) :=
        Session_Name (Session_Name'First .. Session_Name'First + This.Session_Len - 1);
   end Start;

   function Frame_Path (This : Recorder_T; Idx : Positive) return String is
   begin
      return This.Session_Dir (1 .. This.Session_Len) & "_frame_" &
        Format_Frame_Index (Idx) & ".bmp";
   end Frame_Path;

   procedure Capture_Frame
     (This     : in out Recorder_T;
      Port     : Glyph.Simulator.I2C.Simulated_I2C_Port;
      Scale    : Positive := 4;
      FG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.OLED_White;
      BG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.Background_Dark)
   is
   begin
      if not This.Active then
         This.Start ("session");
      end if;

      This.Frame_Index := This.Frame_Index + 1;
      Glyph.Simulator.Exporter.Export_BMP
        (Port      => Port,
         File_Path => This.Frame_Path (This.Frame_Index),
         Scale     => Scale,
         FG_Color  => FG_Color,
         BG_Color  => BG_Color);
   end Capture_Frame;

   procedure Capture_Frame
     (This  : in out Recorder_T;
      Port  : Glyph.Simulator.SPI.Simulated_SPI_Port;
      Scale : Positive := 1)
   is
   begin
      if not This.Active then
         This.Start ("session");
      end if;

      This.Frame_Index := This.Frame_Index + 1;
      Port.Export_BMP
        (File_Path => This.Frame_Path (This.Frame_Index),
         Scale     => Scale);
   end Capture_Frame;

   procedure Capture_Frame
     (This     : in out Recorder_T;
      Canvas   : Glyph.Canvas.C128x64_Mono.Instance;
      Scale    : Positive := 4;
      FG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.OLED_White;
      BG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.Background_Dark)
   is
   begin
      if not This.Active then
         This.Start ("session");
      end if;

      This.Frame_Index := This.Frame_Index + 1;
      Glyph.Simulator.Exporter.Export_BMP
        (Canvas    => Canvas,
         File_Path => This.Frame_Path (This.Frame_Index),
         Scale     => Scale,
         FG_Color  => FG_Color,
         BG_Color  => BG_Color);
   end Capture_Frame;

   procedure Capture_Frame
     (This   : in out Recorder_T;
      Canvas : Glyph.Canvas.C240x320_RGB565.Instance;
      Scale  : Positive := 1)
   is
      Temp_Port : aliased Glyph.Simulator.SPI.Simulated_SPI_Port;
      DC_Pin    : aliased Glyph.Simulator.SPI.Simulated_GPIO_Point;
      Stream_Data : Glyph.Transport.Byte_Array (1 .. 240 * 320 * 2);
   begin
      if not This.Active then
         This.Start ("session");
      end if;

      Canvas.Export_Window_Stream (0, 239, 0, 319, Stream_Data);
      Temp_Port.Connect_DC (DC_Pin'Unchecked_Access);

      This.Frame_Index := This.Frame_Index + 1;
      Temp_Port.Export_BMP
        (File_Path => This.Frame_Path (This.Frame_Index),
         Scale     => Scale);
   end Capture_Frame;

   function Frame_Count (This : Recorder_T) return Natural is
   begin
      return This.Frame_Index;
   end Frame_Count;

   procedure Cleanup_Frame_Files (This : in out Recorder_T) is
      Success : Boolean;
   begin
      for I in 1 .. This.Frame_Index loop
         GNAT.OS_Lib.Delete_File (This.Frame_Path (I), Success);
      end loop;
   end Cleanup_Frame_Files;

   procedure Export_GIF
     (This        : in out Recorder_T;
      Output_Path : String;
      FPS         : Positive := 10;
      Keep_Frames : Boolean := True)
   is
      FFmpeg_Path : constant String := Find_FFmpeg;
      Pattern     : constant String :=
        This.Session_Dir (1 .. This.Session_Len) & "_frame_%05d.bmp";
      FPS_Str     : constant String :=
        Ada.Strings.Fixed.Trim (Positive'Image (FPS), Ada.Strings.Both);
      Filter      : constant String :=
        "fps=" & FPS_Str & ",split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer";
      Success     : Boolean;
   begin
      if This.Frame_Index = 0 then
         Ada.Text_IO.Put_Line ("Error: Cannot export GIF: No frames captured.");
         return;
      end if;

      if This.Frame_Index = 1 then
         declare
            Single_Frame : constant String :=
              This.Session_Dir (1 .. This.Session_Len) & "_frame_00001.bmp";
            Args : GNAT.OS_Lib.Argument_List :=
              [new String'("-y"),
               new String'("-loop"),
               new String'("1"),
               new String'("-t"),
               new String'("2"),
               new String'("-i"),
               new String'(Single_Frame),
               new String'("-vf"),
               new String'("split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse"),
               new String'(Output_Path)];
         begin
            GNAT.OS_Lib.Spawn (FFmpeg_Path, Args, Success);
            for I in Args'Range loop
               GNAT.OS_Lib.Free (Args (I));
            end loop;
         end;
      else
         declare
            Args : GNAT.OS_Lib.Argument_List :=
              [new String'("-y"),
               new String'("-framerate"),
               new String'(FPS_Str),
               new String'("-i"),
               new String'(Pattern),
               new String'("-vf"),
               new String'(Filter),
               new String'(Output_Path)];
         begin
            GNAT.OS_Lib.Spawn (FFmpeg_Path, Args, Success);
            for I in Args'Range loop
               GNAT.OS_Lib.Free (Args (I));
            end loop;
         end;
      end if;

      if Success then
         Ada.Text_IO.Put_Line
           ("Exported GIF: " & Output_Path & " (" &
            Natural'Image (This.Frame_Index) & " frames at" &
            Positive'Image (FPS) & " FPS)");
      else
         Ada.Text_IO.Put_Line
           ("Error: ffmpeg failed while exporting GIF: " & Output_Path);
      end if;

      if not Keep_Frames then
         This.Cleanup_Frame_Files;
      end if;
   end Export_GIF;

   procedure Export_Video
     (This        : in out Recorder_T;
      Output_Path : String;
      FPS         : Positive := 30;
      Keep_Frames : Boolean := True)
   is
      FFmpeg_Path : constant String := Find_FFmpeg;
      Pattern     : constant String :=
        This.Session_Dir (1 .. This.Session_Len) & "_frame_%05d.bmp";
      FPS_Str     : constant String :=
        Ada.Strings.Fixed.Trim (Positive'Image (FPS), Ada.Strings.Both);
      Success     : Boolean;
   begin
      if This.Frame_Index = 0 then
         Ada.Text_IO.Put_Line ("Error: Cannot export Video: No frames captured.");
         return;
      end if;

      if This.Frame_Index = 1 then
         declare
            Single_Frame : constant String :=
              This.Session_Dir (1 .. This.Session_Len) & "_frame_00001.bmp";
            Args : GNAT.OS_Lib.Argument_List :=
              [new String'("-y"),
               new String'("-loop"),
               new String'("1"),
               new String'("-t"),
               new String'("3"),
               new String'("-framerate"),
               new String'(FPS_Str),
               new String'("-i"),
               new String'(Single_Frame),
               new String'("-c:v"),
               new String'("libx264"),
               new String'("-pix_fmt"),
               new String'("yuv420p"),
               new String'("-vf"),
               new String'("pad=ceil(iw/2)*2:ceil(ih/2)*2"),
               new String'(Output_Path)];
         begin
            GNAT.OS_Lib.Spawn (FFmpeg_Path, Args, Success);
            for I in Args'Range loop
               GNAT.OS_Lib.Free (Args (I));
            end loop;
         end;
      else
         declare
            Args : GNAT.OS_Lib.Argument_List :=
              [new String'("-y"),
               new String'("-framerate"),
               new String'(FPS_Str),
               new String'("-i"),
               new String'(Pattern),
               new String'("-c:v"),
               new String'("libx264"),
               new String'("-pix_fmt"),
               new String'("yuv420p"),
               new String'("-vf"),
               new String'("pad=ceil(iw/2)*2:ceil(ih/2)*2"),
               new String'(Output_Path)];
         begin
            GNAT.OS_Lib.Spawn (FFmpeg_Path, Args, Success);
            for I in Args'Range loop
               GNAT.OS_Lib.Free (Args (I));
            end loop;
         end;
      end if;

      if Success then
         Ada.Text_IO.Put_Line
           ("Exported Video: " & Output_Path & " (" &
            Natural'Image (This.Frame_Index) & " frames at" &
            Positive'Image (FPS) & " FPS)");
      else
         Ada.Text_IO.Put_Line
           ("Error: ffmpeg failed while exporting Video: " & Output_Path);
      end if;

      if not Keep_Frames then
         This.Cleanup_Frame_Files;
      end if;
   end Export_Video;

   procedure Finish (This : in out Recorder_T) is
   begin
      This.Cleanup_Frame_Files;
      This.Active := False;
      This.Frame_Index := 0;
   end Finish;

end Glyph.Simulator.Recorder;
