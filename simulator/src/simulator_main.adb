with Ada.Text_IO;
with Ada.Directories;
with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with GNAT.OS_Lib;

with Glyph.Colors;
with Glyph.Fonts;
with Glyph.Display.SSD1306;
with Glyph.Display.ILI9341;
with Glyph.Simulator.I2C;
with Glyph.Simulator.SPI;
with Glyph.Simulator.Exporter;
with Glyph.Simulator.Recorder;

procedure Simulator_Main is

   use Ada.Text_IO;

   function Trim_Trailing_Slash (Path : String) return String is
      P : constant String :=
        Ada.Strings.Fixed.Trim (Path, Ada.Strings.Both);
   begin
      if P'Length > 1 and then P (P'Last) in '/' | '\' then
         return P (P'First .. P'Last - 1);
      else
         return P;
      end if;
   end Trim_Trailing_Slash;

   function Ends_With (Str : String; Suffix : String) return Boolean is
   begin
      if Str'Length < Suffix'Length then
         return False;
      end if;
      return Str (Str'Last - Suffix'Length + 1 .. Str'Last) = Suffix;
   end Ends_With;

   function Resolve_Target_Dir return String is
      use Ada.Command_Line;
   begin
      if Argument_Count >= 1 then
         declare
            Arg : constant String :=
              Ada.Strings.Fixed.Trim (Argument (1), Ada.Strings.Both);
         begin
            if Arg = "-h" or else Arg = "--help" then
               Put_Line ("Usage: simulator_main [TARGET_PROJECT_PATH]");
               Put_Line ("");
               Put_Line ("Simulate display hardware and export animation frames, GIFs, and videos.");
               Put_Line ("");
               Put_Line ("Arguments:");
               Put_Line ("  TARGET_PROJECT_PATH   Path to target project directory (default: './example' or './')");
               Put_Line ("                        Exports are written to <TARGET_PROJECT_PATH>/exports/");
               Put_Line ("                        (or directly to TARGET_PROJECT_PATH if it already ends in 'exports')");
               Put_Line ("");
               Put_Line ("Options:");
               Put_Line ("  -h, --help            Show this help message and exit");
               GNAT.OS_Lib.OS_Exit (0);
            end if;

            declare
               Clean_Arg : constant String := Trim_Trailing_Slash (Arg);
            begin
               if Ends_With (Clean_Arg, "exports") then
                  return Clean_Arg & "/";
               else
                  return Clean_Arg & "/exports/";
               end if;
            end;
         end;
      end if;

      --  Default fallback when no argument provided:
      if Ada.Directories.Exists ("example") then
         return "example/exports/";
      elsif Ada.Directories.Exists ("exports") then
         return "exports/";
      else
         return "exports/";
      end if;
   end Resolve_Target_Dir;

   function Get_Export_Dir return String is
      Target_Dir : constant String := Resolve_Target_Dir;
      Dir_To_Create : constant String := Trim_Trailing_Slash (Target_Dir);
   begin
      if not Ada.Directories.Exists (Dir_To_Create) then
         Ada.Directories.Create_Path (Dir_To_Create);
      end if;
      return Target_Dir;
   end Get_Export_Dir;

   Export_Path : constant String := Get_Export_Dir;

   Current_Sim_Frame : Natural := 0;

   --  SSD1306 OLED test animation
   procedure Draw_SSD1306
     (OLED : in out Glyph.Display.SSD1306.Display_T; Frame : Natural)
   is
      use Ada.Numerics;
      use Ada.Numerics.Elementary_Functions;

      Progress : constant Integer := (Frame mod 30) * 104 / 29;
      Radius   : constant Integer := 6 + (Frame mod 12);
      Ang      : constant Float := Float (Frame mod 24) * (2.0 * Pi / 24.0);
      Dot_X    : constant Integer := 64 + Integer (22.0 * Cos (Ang));
      Dot_Y    : constant Integer := 28 + Integer (15.0 * Sin (Ang));
   begin
      OLED.Clear;

      OLED.Paint_Rectangle (0, 0, 128, 64);
      OLED.Paint_Text (6, 4, "GLYPH OLED");

      OLED.Paint_Circle (64, 28, Radius);
      OLED.Paint_Filled_Circle (64, 28, 3);
      OLED.Paint_Filled_Rectangle (Dot_X - 1, Dot_Y - 1, 3, 3);

      OLED.Paint_Rectangle (10, 48, 108, 8);
      if Progress > 0 then
         OLED.Paint_Filled_Rectangle (12, 50, Progress, 4);
      end if;
   end Draw_SSD1306;

   --  ILI9341 color TFT test animation
   procedure Draw_ILI9341 (Disp : in out Glyph.Display.ILI9341.Display_T) is
      use Ada.Numerics;
      use Ada.Numerics.Elementary_Functions;

      C_Dark_Blue : constant Glyph.Colors.RGB565 := 16#0810#;
      C_Cyan      : constant Glyph.Colors.RGB565 := 16#07FF#;
      C_Orange    : constant Glyph.Colors.RGB565 := 16#FD20#;
      C_Yellow    : constant Glyph.Colors.RGB565 := 16#FFE0#;
      C_Green     : constant Glyph.Colors.RGB565 := 16#07E0#;
      C_White     : constant Glyph.Colors.RGB565 := 16#FFFF#;
      C_Slate     : constant Glyph.Colors.RGB565 := 16#29A6#;

      Ball1_X : constant Integer := 30 + ((Current_Sim_Frame * 9) mod 180);
      Ball1_Y : constant Integer := 70 + ((Current_Sim_Frame * 7) mod 70);

      Ball2_X : constant Integer := 210 - ((Current_Sim_Frame * 8) mod 180);
      Ball2_Y : constant Integer := 130 - ((Current_Sim_Frame * 6) mod 60);

      Spin_Ang : constant Float :=
        Float (Current_Sim_Frame mod 24) * (2.0 * Pi / 24.0);
      Hand_X   : constant Integer := 120 + Integer (32.0 * Cos (Spin_Ang));
      Hand_Y   : constant Integer := 185 + Integer (32.0 * Sin (Spin_Ang));

      Progress : constant Integer := (Current_Sim_Frame mod 30) * 196 / 29;

   begin
      Disp.Clear (16#0000#);

      Disp.Paint_Filled_Rectangle (0, 0, 240, 36, C_Dark_Blue);
      Disp.Paint_Line (0, 36, 239, 36, C_Cyan);
      Disp.Paint_Text (20, 12, "GLYPH DISPLAY DEMO", Color => C_White);

      Disp.Paint_Filled_Circle (Ball1_X, Ball1_Y, 14, Color => C_Cyan);
      Disp.Paint_Filled_Circle (Ball2_X, Ball2_Y, 12, Color => C_Orange);

      Disp.Paint_Circle (120, 185, 36, Color => C_Slate);
      Disp.Paint_Line (120, 185, Hand_X, Hand_Y, C_Yellow);
      Disp.Paint_Filled_Circle (120, 185, 4, Color => C_White);

      Disp.Paint_Text (20, 240, "LOADING...", Color => C_White);
      Disp.Paint_Rectangle (20, 260, 200, 16, Color => C_Slate);
      if Progress > 0 then
         Disp.Paint_Filled_Rectangle (22, 262, Progress, 12, C_Green);
      end if;
   end Draw_ILI9341;

   procedure Run_SSD1306 is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      Put_Line ("Rendering SSD1306 animation...");

      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);

      Rec.Start (Export_Path & "ssd1306_frame");

      for Step in 0 .. 23 loop
         Draw_SSD1306 (OLED, Step);
         OLED.Render;
         Rec.Capture_Frame (Port => Port);

         if Step = 0 then
            Glyph.Simulator.Exporter.Export_BMP
              (Port      => Port,
               File_Path => Export_Path & "ssd1306_animation.bmp");
         end if;
      end loop;

      Rec.Export_GIF (Export_Path & "ssd1306_animation.gif", FPS => 12);
      Rec.Export_Video (Export_Path & "ssd1306_animation.mp4", FPS => 30);
      Rec.Finish;

      Put_Line ("Exported SSD1306 media to " & Export_Path);
   end Run_SSD1306;

   procedure Run_ILI9341 is
      Port   : aliased Glyph.Simulator.SPI.Simulated_SPI_Port;
      DC_Pin : aliased Glyph.Simulator.SPI.Simulated_GPIO_Point;
      TFT    : Glyph.Display.ILI9341.Display_T := Glyph.Display.ILI9341.Create;
      Rec    : Glyph.Simulator.Recorder.Recorder_T;
   begin
      Put_Line ("Rendering ILI9341 animation...");

      Port.Connect_DC (DC_Pin'Unrestricted_Access);
      TFT.Set_Default_Font (Glyph.Fonts.Font_5x7);
      TFT.Init (SPI => Port'Access, DC => DC_Pin'Unrestricted_Access);

      Rec.Start (Export_Path & "ili9341_frame");

      for Step in 0 .. 23 loop
         Current_Sim_Frame := Step;
         TFT.Render_Scene (Draw_ILI9341'Access);
         Rec.Capture_Frame (Port => Port);

         if Step = 0 then
            Glyph.Simulator.SPI.Export_BMP
              (Port      => Port,
               File_Path => Export_Path & "ili9341_animation.bmp");
         end if;
      end loop;

      Rec.Export_GIF (Export_Path & "ili9341_animation.gif", FPS => 12);
      Rec.Export_Video (Export_Path & "ili9341_animation.mp4", FPS => 30);
      Rec.Finish;

      Put_Line ("Exported ILI9341 media to " & Export_Path);
   end Run_ILI9341;

begin
   Put_Line ("Target directory: " & Export_Path);

   Run_SSD1306;
   Run_ILI9341;

   Put_Line ("Done.");
end Simulator_Main;
