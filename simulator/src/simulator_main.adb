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

   --  SSD1306 OLED Music Player Design ("Sailor Song" by Gigi Perez)
   procedure Draw_SSD1306
     (OLED : in out Glyph.Display.SSD1306.Display_T; Frame : Natural)
   is
      use Ada.Numerics;
      use Ada.Numerics.Elementary_Functions;

      Phase : constant Float := Float (Frame mod 60) * (2.0 * Pi / 60.0);

      --  Spool rotation angles (both spools spin steadily)
      Spool_Ang : constant Float := Phase * 3.0;

      --  Smooth full-width timeline scrubber (X: 4 .. 122)
      Scrub_X : constant Integer := 4 + (Frame mod 60) * 118 / 59;

      procedure Draw_Spool (CX, CY : Integer) is
      begin
         OLED.Paint_Circle (CX, CY, 4);
         OLED.Paint_Filled_Circle (CX, CY, 1);

         --  3 rotating spokes per spool
         for S in 0 .. 2 loop
            declare
               Spoke_Ang : constant Float :=
                 Spool_Ang + Float (S) * (2.0 * Pi / 3.0);
               SX : constant Integer := CX + Integer (3.0 * Cos (Spoke_Ang));
               SY : constant Integer := CY + Integer (3.0 * Sin (Spoke_Ang));
            begin
               OLED.Paint_Line (CX, CY, SX, SY);
            end;
         end loop;
      end Draw_Spool;

   begin
      OLED.Clear;

      --  Top Status Bar
      OLED.Paint_Text (4, 1, "> PLAY");
      OLED.Paint_Text (52, 1, "VOL ||.");
      OLED.Paint_Text (96, 1, "FLAC");
      OLED.Paint_Line (0, 9, 127, 9);

      --  Left Side: Retro-Modern Cassette Tape (X: 4..40, Y: 13..45)
      --  Outer cassette shell
      OLED.Paint_Rectangle (4, 13, 38, 29);
      --  Inner tape window
      OLED.Paint_Rectangle (10, 18, 26, 14);

      --  Tape spools
      Draw_Spool (16, 25);
      Draw_Spool (30, 25);

      --  Magnetic tape guide line
      OLED.Paint_Line (16, 29, 30, 29);

      --  Cassette bottom trapezoid bevel
      OLED.Paint_Line (10, 42, 14, 38);
      OLED.Paint_Line (14, 38, 28, 38);
      OLED.Paint_Line (28, 38, 32, 42);

      --  Right Side: Song Information
      OLED.Paint_Text (48, 13, "SAILOR SONG");
      OLED.Paint_Text (48, 22, "GIGI PEREZ");

      --  Dynamic 8-Channel Audio Spectrum Equalizer (X: 48..124, Y: 33..43)
      for B in 0 .. 7 loop
         declare
            Band_F : constant Float := Float (B) * 0.85 + Phase * 3.0;
            H_Raw  : constant Float := (Sin (Band_F) + 1.0) / 2.0;
            H      : constant Integer := 2 + Integer (H_Raw * 8.0);
            Bar_X  : constant Integer := 48 + B * 5;
         begin
            OLED.Paint_Filled_Rectangle (Bar_X, 43 - H, 3, H);
         end;
      end loop;

      --  Sampling rate badge
      OLED.Paint_Text (94, 34, "48kHz");

      --  Bottom Section: Full-Width Scrubber & Controls
      --  Scrubber track & moving playhead
      OLED.Paint_Line (4, 49, 123, 49);
      OLED.Paint_Line (4, 49, Scrub_X, 49);
      OLED.Paint_Filled_Rectangle (Scrub_X - 1, 47, 3, 5);

      --  Timestamps & transport indicators
      OLED.Paint_Text (4, 55, "01:14");
      OLED.Paint_Text (46, 55, "|<<  ||  >>|");
      OLED.Paint_Text (92, 55, "-02:37");
   end Draw_SSD1306;

   --  ILI9341 240x320 16-bit Color Calculator Design
   procedure Draw_ILI9341 (Disp : in out Glyph.Display.ILI9341.Display_T) is
      use Ada.Numerics.Elementary_Functions;

      --  Palette
      C_Body     : constant Glyph.Colors.RGB565 := 16#10E2#; -- #111827 Dark chassis
      C_LCD_BG   : constant Glyph.Colors.RGB565 := 16#08A3#; -- #0D131F LCD obsidian
      C_LCD_Edge : constant Glyph.Colors.RGB565 := 16#2187#; -- #202F44 LCD frame
      C_Num_Key  : constant Glyph.Colors.RGB565 := 16#1946#; -- #1C2432 Key charcoal
      C_Num_Edge : constant Glyph.Colors.RGB565 := 16#29C8#; -- #293649 Key border
      C_Fn_Key   : constant Glyph.Colors.RGB565 := 16#2A0C#; -- #2C3E55 Function key
      C_Op_Key   : constant Glyph.Colors.RGB565 := 16#FA80#; -- #FF5500 Operator orange
      C_Active   : constant Glyph.Colors.RGB565 := 16#07FF#; -- #00F5FF Active cyan
      C_White    : constant Glyph.Colors.RGB565 := 16#FFFF#; -- #FFFFFF White
      C_Muted    : constant Glyph.Colors.RGB565 := 16#7BCF#; -- #7B889B Muted gray
      C_Green    : constant Glyph.Colors.RGB565 := 16#07E0#; -- #00E676 Green

      Step : constant Natural := Current_Sim_Frame mod 60;

      --  Key matrix definitions (5 rows x 4 columns)
      --  Key coordinates: Col 0..3 at 8, 66, 124, 182 (W=50)
      --                   Row 0..4 at 96, 140, 184, 228, 272 (H=38)

      --  Determine active key tapped in this animation step:
      --  Step 0..14:  Key '2'  (Row 3, Col 1)
      --  Step 15..29: Key 'x'  (Row 1, Col 3)
      --  Step 30..44: Key '3'  (Row 3, Col 2)
      --  Step 45..59: Key '='  (Row 4, Col 3)
      Active_R : Integer := -1;
      Active_C : Integer := -1;

      procedure Draw_Key
        (R, C    : Natural;
         Label  : String;
         Kind   : Natural; -- 0: Num, 1: Fn, 2: Op
         Active : Boolean)
      is
         KX : constant Integer := 8 + C * 58;
         KY : constant Integer := 96 + R * 44;
         KW : constant Integer := 50;
         KH : constant Integer := 38;

         Fill_Col : Glyph.Colors.RGB565;
         Text_Col : Glyph.Colors.RGB565;
         Text_X   : Integer;
         Text_Y   : constant Integer := KY + 15;
      begin
         if Active then
            Fill_Col := (if Kind = 2 then C_White else C_Active);
            Text_Col := 16#0000#;
         else
            case Kind is
               when 1 =>
                  Fill_Col := C_Fn_Key;
                  Text_Col := C_Active;
               when 2 =>
                  Fill_Col := C_Op_Key;
                  Text_Col := C_White;
               when others =>
                  Fill_Col := C_Num_Key;
                  Text_Col := C_White;
            end case;
         end if;

         --  Key body & bevel
         Disp.Paint_Filled_Rectangle (KX, KY, KW, KH, Fill_Col);
         Disp.Paint_Rectangle (KX, KY, KW, KH, Color => (if Active then C_White else C_Num_Edge));

         --  Center text
         Text_X := KX + (KW - Label'Length * 6) / 2;
         Disp.Paint_Text (Text_X, Text_Y, Label, Color => Text_Col);
      end Draw_Key;

   begin
      --  Determine currently pressed key
      if Step < 15 then
         Active_R := 3; Active_C := 1; -- '2'
      elsif Step < 30 then
         Active_R := 1; Active_C := 3; -- 'x'
      elsif Step < 45 then
         Active_R := 3; Active_C := 2; -- '3'
      else
         Active_R := 4; Active_C := 3; -- '='
      end if;

      Disp.Clear (C_Body);

      --  =======================================================
      --  Top LCD Screen Region (Y: 8 .. 88)
      --  =======================================================
      Disp.Paint_Filled_Rectangle (8, 8, 224, 80, C_LCD_BG);
      Disp.Paint_Rectangle
        (8, 8, 224, 80,
         Color => (if Step >= 45 then C_Green else C_LCD_Edge));

      --  Top status row in LCD
      Disp.Paint_Text (16, 14, "DEG", Color => C_Muted);
      Disp.Paint_Text (50, 14, "FIX:2", Color => C_Muted);

      --  Mini graphing LCD wave on top-right
      for WX in 0 .. 36 loop
         declare
            Wave_Ang : constant Float :=
              Float (WX) * 0.25 + Float (Step) * 0.1047;
            WY : constant Integer := 18 + Integer (4.0 * Sin (Wave_Ang));
         begin
            Disp.Paint_Pixel (176 + WX, WY, Color => C_Active);
         end;
      end loop;

      --  Formula history line
      if Step < 15 then
         Disp.Paint_Text (16, 32, "ENTER VALUE:", Color => C_Muted);
      elsif Step < 30 then
         Disp.Paint_Text (16, 32, "240 * ...", Color => C_Muted);
      elsif Step < 45 then
         Disp.Paint_Text (16, 32, "240 * 3 =", Color => C_Muted);
      else
         Disp.Paint_Text (16, 32, "240 * 3 = 720.00", Color => C_Green);
      end if;

      --  Main Number Display
      if Step < 15 then
         Disp.Paint_Text (16, 54, "240", Scale => 2, Color => C_White);
      elsif Step < 30 then
         Disp.Paint_Text (16, 54, "240 *", Scale => 2, Color => C_Active);
      elsif Step < 45 then
         Disp.Paint_Text (16, 54, "3", Scale => 2, Color => C_White);
      else
         Disp.Paint_Text (16, 54, "720.00", Scale => 2, Color => C_White);
      end if;

      --  Blinking cursor
      if (Step mod 20) < 10 then
         declare
            Cur_X : constant Integer :=
              (if Step < 15 then 64
               elsif Step < 30 then 88
               elsif Step < 45 then 38
               else 106);
         begin
            Disp.Paint_Filled_Rectangle (Cur_X, 54, 3, 14, C_Active);
         end;
      end if;

      --  =======================================================
      --  Keypad Buttons (5 rows x 4 columns)
      --  =======================================================
      --  Row 0: Functions
      Draw_Key (0, 0, "AC", 1, Active_R = 0 and then Active_C = 0);
      Draw_Key (0, 1, "( )", 1, Active_R = 0 and then Active_C = 1);
      Draw_Key (0, 2, "%", 1, Active_R = 0 and then Active_C = 2);
      Draw_Key (0, 3, "/", 2, Active_R = 0 and then Active_C = 3);

      --  Row 1
      Draw_Key (1, 0, "7", 0, Active_R = 1 and then Active_C = 0);
      Draw_Key (1, 1, "8", 0, Active_R = 1 and then Active_C = 1);
      Draw_Key (1, 2, "9", 0, Active_R = 1 and then Active_C = 2);
      Draw_Key (1, 3, "*", 2, Active_R = 1 and then Active_C = 3);

      --  Row 2
      Draw_Key (2, 0, "4", 0, Active_R = 2 and then Active_C = 0);
      Draw_Key (2, 1, "5", 0, Active_R = 2 and then Active_C = 1);
      Draw_Key (2, 2, "6", 0, Active_R = 2 and then Active_C = 2);
      Draw_Key (2, 3, "-", 2, Active_R = 2 and then Active_C = 3);

      --  Row 3
      Draw_Key (3, 0, "1", 0, Active_R = 3 and then Active_C = 0);
      Draw_Key (3, 1, "2", 0, Active_R = 3 and then Active_C = 1);
      Draw_Key (3, 2, "3", 0, Active_R = 3 and then Active_C = 2);
      Draw_Key (3, 3, "+", 2, Active_R = 3 and then Active_C = 3);

      --  Row 4
      Draw_Key (4, 0, "0", 0, Active_R = 4 and then Active_C = 0);
      Draw_Key (4, 1, ".", 0, Active_R = 4 and then Active_C = 1);
      Draw_Key (4, 2, "DEL", 1, Active_R = 4 and then Active_C = 2);
      Draw_Key (4, 3, "=", 2, Active_R = 4 and then Active_C = 3);

   end Draw_ILI9341;

   procedure Run_SSD1306 is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      Put_Line ("Rendering SSD1306 animation (60 frames at 30 FPS)...");

      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);

      Rec.Start (Export_Path & "ssd1306_frame");

      for Step in 0 .. 59 loop
         Draw_SSD1306 (OLED, Step);
         OLED.Render;
         Rec.Capture_Frame (Port => Port);

         if Step = 0 then
            Glyph.Simulator.Exporter.Export_BMP
              (Port      => Port,
               File_Path => Export_Path & "ssd1306_animation.bmp");
         end if;
      end loop;

      Rec.Export_GIF (Export_Path & "ssd1306_animation.gif", FPS => 25);
      Rec.Export_Video (Export_Path & "ssd1306_animation.mp4", FPS => 25);
      Rec.Finish;

      Put_Line ("Exported SSD1306 media to " & Export_Path);
   end Run_SSD1306;

   procedure Run_ILI9341 is
      Port   : aliased Glyph.Simulator.SPI.Simulated_SPI_Port;
      DC_Pin : aliased Glyph.Simulator.SPI.Simulated_GPIO_Point;
      TFT    : Glyph.Display.ILI9341.Display_T := Glyph.Display.ILI9341.Create;
      Rec    : Glyph.Simulator.Recorder.Recorder_T;
   begin
      Put_Line ("Rendering ILI9341 animation (60 frames at 25 FPS)...");

      Port.Connect_DC (DC_Pin'Unrestricted_Access);
      TFT.Set_Default_Font (Glyph.Fonts.Font_5x7);
      TFT.Init (SPI => Port'Access, DC => DC_Pin'Unrestricted_Access);

      Rec.Start (Export_Path & "ili9341_frame");

      for Step in 0 .. 59 loop
         Current_Sim_Frame := Step;
         TFT.Render_Scene (Draw_ILI9341'Access);
         Rec.Capture_Frame (Port => Port);

         if Step = 0 then
            Glyph.Simulator.SPI.Export_BMP
              (Port      => Port,
               File_Path => Export_Path & "ili9341_animation.bmp");
         end if;
      end loop;

      Rec.Export_GIF (Export_Path & "ili9341_animation.gif", FPS => 25);
      Rec.Export_Video (Export_Path & "ili9341_animation.mp4", FPS => 25);
      Rec.Finish;

      Put_Line ("Exported ILI9341 media to " & Export_Path);
   end Run_ILI9341;

   --  =============================================================
   --  Documentation Tutorial & Example GIF Generators
   --  Outputs ONLY what each example code produces at real speed.
   --  =============================================================

   --  First Program (docs/index.html)
   procedure Render_Doc_First_Program (Out_Dir : String) is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);
      Rec.Start (Out_Dir & "doc_first_prog");

      OLED.Clear;
      OLED.Paint_Rectangle (0, 0, 128, 64);
      OLED.Paint_Circle (Center_X => 64, Center_Y => 32, Radius => 18);
      OLED.Paint_Text (X => 48, Y => 29, Text => "GLYPH");
      OLED.Render;
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "first_program.gif");
      Rec.Finish;
   end Render_Doc_First_Program;

   --  Lesson 2: Plotting Pixels & Out-of-Bounds Safety
   procedure Render_Doc_Lesson_2 (Out_Dir : String) is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);
      Rec.Start (Out_Dir & "doc_l2");

      OLED.Clear;
      OLED.Paint_Pixel (X => 0,   Y => 0);
      OLED.Paint_Pixel (X => 127, Y => 0);
      OLED.Paint_Pixel (X => 0,   Y => 63);
      OLED.Paint_Pixel (X => 127, Y => 63);
      OLED.Paint_Pixel (X => 250, Y => 90); -- Safely clipped
      OLED.Render;
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "lesson_2_pixels.gif");
      Rec.Finish;
   end Render_Doc_Lesson_2;

   --  Lesson 3: Lines & Bresenham Rasterization
   procedure Render_Doc_Lesson_3 (Out_Dir : String) is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);
      Rec.Start (Out_Dir & "doc_l3");

      OLED.Clear;
      OLED.Paint_Line (X1 => 0, Y1 => 0, X2 => 127, Y2 => 63);
      OLED.Paint_Line (X1 => 127, Y1 => 0, X2 => 0, Y2 => 63);
      OLED.Paint_Line (X1 => 0, Y1 => 32, X2 => 127, Y2 => 32);
      OLED.Paint_Line (X1 => 64, Y1 => 0, X2 => 64, Y2 => 63);
      OLED.Render;
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "lesson_3_lines.gif");
      Rec.Finish;
   end Render_Doc_Lesson_3;

   --  Lesson 4: Rectangles & Progress Meters
   procedure Render_Doc_Lesson_4 (Out_Dir : String) is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);
      Rec.Start (Out_Dir & "doc_l4");

      OLED.Clear;
      OLED.Paint_Rectangle (0, 0, 128, 64);
      OLED.Paint_Rectangle (10, 48, 108, 8);
      OLED.Paint_Filled_Rectangle (12, 50, 75, 4);
      OLED.Render;
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "lesson_4_rectangles.gif");
      Rec.Finish;
   end Render_Doc_Lesson_4;

   --  Lesson 5: Circles, Arcs & Gauges
   procedure Render_Doc_Lesson_5 (Out_Dir : String) is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);
      Rec.Start (Out_Dir & "doc_l5");

      OLED.Clear;
      OLED.Paint_Circle (Center_X => 64, Center_Y => 32, Radius => 24);
      OLED.Paint_Circle (Center_X => 64, Center_Y => 32, Radius => 14);
      OLED.Paint_Filled_Circle (Center_X => 64, Center_Y => 32, Radius => 4);
      OLED.Render;
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "lesson_5_circles.gif");
      Rec.Finish;
   end Render_Doc_Lesson_5;

   --  Lesson 6: ILI9341 Color TFT (240x320)
   procedure Draw_Lesson_6 (TFT : in out Glyph.Display.ILI9341.Display_T) is
   begin
      TFT.Clear (Glyph.Colors.Black);
      TFT.Paint_Rectangle (4, 4, 232, 312, Color => Glyph.Colors.White);
      TFT.Paint_Filled_Circle (120, 160, 40, Color => 16#07E0#);
   end Draw_Lesson_6;

   procedure Render_Doc_Lesson_6 (Out_Dir : String) is
      Port   : aliased Glyph.Simulator.SPI.Simulated_SPI_Port;
      DC_Pin : aliased Glyph.Simulator.SPI.Simulated_GPIO_Point;
      TFT    : Glyph.Display.ILI9341.Display_T := Glyph.Display.ILI9341.Create;
      Rec    : Glyph.Simulator.Recorder.Recorder_T;
   begin
      Port.Connect_DC (DC_Pin'Unrestricted_Access);
      TFT.Set_Default_Font (Glyph.Fonts.Font_5x7);
      TFT.Init (SPI => Port'Access, DC => DC_Pin'Unrestricted_Access);
      Rec.Start (Out_Dir & "doc_l6");

      TFT.Render_Scene (Draw_Lesson_6'Access);
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "lesson_6_ili9341.gif");
      Rec.Finish;
   end Render_Doc_Lesson_6;

   --  Lesson 7: Color Shapes & Filled Triangles
   procedure Draw_Lesson_7 (TFT : in out Glyph.Display.ILI9341.Display_T) is
      C_Red  : constant Glyph.Colors.RGB565 := 16#F800#;
      C_Cyan : constant Glyph.Colors.RGB565 := 16#07FF#;
   begin
      TFT.Clear (Glyph.Colors.Black);
      TFT.Paint_Filled_Triangle
        (X1 => 120, Y1 => 40,
         X2 => 80,  Y2 => 110,
         X3 => 160, Y3 => 110,
         Color => C_Red);
      TFT.Paint_Line (20, 130, 220, 130, Color => C_Cyan);
   end Draw_Lesson_7;

   procedure Render_Doc_Lesson_7 (Out_Dir : String) is
      Port   : aliased Glyph.Simulator.SPI.Simulated_SPI_Port;
      DC_Pin : aliased Glyph.Simulator.SPI.Simulated_GPIO_Point;
      TFT    : Glyph.Display.ILI9341.Display_T := Glyph.Display.ILI9341.Create;
      Rec    : Glyph.Simulator.Recorder.Recorder_T;
   begin
      Port.Connect_DC (DC_Pin'Unrestricted_Access);
      TFT.Set_Default_Font (Glyph.Fonts.Font_5x7);
      TFT.Init (SPI => Port'Access, DC => DC_Pin'Unrestricted_Access);
      Rec.Start (Out_Dir & "doc_l7");

      TFT.Render_Scene (Draw_Lesson_7'Access);
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "lesson_7_triangles.gif");
      Rec.Finish;
   end Render_Doc_Lesson_7;

   --  Lesson 8: Text & Bitmap Fonts
   procedure Render_Doc_Lesson_8 (Out_Dir : String) is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);
      Rec.Start (Out_Dir & "doc_l8");

      OLED.Clear;
      OLED.Paint_Text (X => 10, Y => 10, Text => "SYS: READY");
      OLED.Paint_Text (X => 10, Y => 30, Text => "24.5 C", Scale => 2);
      OLED.Render;
      Rec.Capture_Frame (Port => Port);

      Rec.Export_GIF (Out_Dir & "lesson_8_text.gif");
      Rec.Finish;
   end Render_Doc_Lesson_8;

   --  Lesson 9: RP2040 Hardware Timer Animation Loop
   --  Exact raw 30 FPS hardware speed (~33ms delay per frame in code)
   procedure Render_Doc_Lesson_9 (Out_Dir : String) is
      Port : aliased Glyph.Simulator.I2C.Simulated_I2C_Port;
      OLED : Glyph.Display.SSD1306.Display_T := Glyph.Display.SSD1306.Create;
      Rec  : Glyph.Simulator.Recorder.Recorder_T;
   begin
      OLED.Set_Default_Font (Glyph.Fonts.Font_5x7);
      OLED.Init (Port'Access);
      Rec.Start (Out_Dir & "doc_l9");

      for Frame in 0 .. 31 loop
         OLED.Clear;

         declare
            Sweep_X : constant Integer := (Frame * 4) mod 128;
         begin
            OLED.Paint_Line (64, 32, Sweep_X, 0);
         end;

         OLED.Paint_Rectangle (0, 0, 128, 64);
         OLED.Paint_Text (10, 48, "SCANNING...");
         OLED.Render;

         Rec.Capture_Frame (Port => Port);
      end loop;

      --  Exact raw frame rate matching RP.Device.Timer.Delay_Milliseconds (33)
      Rec.Export_GIF (Out_Dir & "lesson_9_animation.gif", FPS => 30);
      Rec.Finish;
   end Render_Doc_Lesson_9;

   procedure Run_Docs_Media (Out_Dir : String) is
   begin
      Put_Line ("Generating exact raw documentation GIFs in " & Out_Dir & "...");
      Render_Doc_First_Program (Out_Dir);
      Render_Doc_Lesson_2 (Out_Dir);
      Render_Doc_Lesson_3 (Out_Dir);
      Render_Doc_Lesson_4 (Out_Dir);
      Render_Doc_Lesson_5 (Out_Dir);
      Render_Doc_Lesson_6 (Out_Dir);
      Render_Doc_Lesson_7 (Out_Dir);
      Render_Doc_Lesson_8 (Out_Dir);
      Render_Doc_Lesson_9 (Out_Dir);
      Put_Line ("All documentation GIFs generated successfully.");
   end Run_Docs_Media;

begin
   if Ada.Command_Line.Argument_Count >= 1
     and then Ada.Command_Line.Argument (1) = "--docs"
   then
      Run_Docs_Media ("docs/assets/");
   else
      Put_Line ("Target directory: " & Export_Path);

      Run_SSD1306;
      Run_ILI9341;
      Run_Docs_Media ("docs/assets/");
   end if;

   Put_Line ("Done.");
end Simulator_Main;
