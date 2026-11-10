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

   --  SSD1306 Bento Menu (Home, Music, Settings, Alarm with Active Highlight)
   procedure Draw_SSD1306
     (OLED : in out Glyph.Display.SSD1306.Display_T; Frame : Natural)
   is
      use Glyph.Colors;

      --  4-State Selection Cycle (15 frames each = 60 frames total)
      Sel : constant Natural := (Frame / 15) mod 4;

      procedure Draw_Pixel
        (X, Y : Integer; Col : Glyph.Colors.Monochrome) is
      begin
         OLED.Paint_Pixel (X, Y, Col);
      end Draw_Pixel;

      procedure Draw_HLine
        (X, Y, W : Integer; Col : Glyph.Colors.Monochrome) is
      begin
         for I in 0 .. W - 1 loop
            OLED.Paint_Pixel (X + I, Y, Col);
         end loop;
      end Draw_HLine;

      procedure Draw_VLine
        (X, Y, H : Integer; Col : Glyph.Colors.Monochrome) is
      begin
         for I in 0 .. H - 1 loop
            OLED.Paint_Pixel (X, Y + I, Col);
         end loop;
      end Draw_VLine;

      procedure Draw_Line
        (X1, Y1, X2, Y2 : Integer; Col : Glyph.Colors.Monochrome)
      is
         DX  : constant Integer := abs (X2 - X1);
         DY  : constant Integer := abs (Y2 - Y1);
         SX  : constant Integer := (if X1 < X2 then 1 else -1);
         SY  : constant Integer := (if Y1 < Y2 then 1 else -1);
         Err : Integer := DX - DY;
         CX  : Integer := X1;
         CY  : Integer := Y1;
         E2  : Integer;
      begin
         loop
            OLED.Paint_Pixel (CX, CY, Col);
            exit when CX = X2 and then CY = Y2;
            E2 := 2 * Err;
            if E2 > -DY then
               Err := Err - DY;
               CX  := CX + SX;
            end if;
            if E2 < DX then
               Err := Err + DX;
               CY  := CY + SY;
            end if;
         end loop;
      end Draw_Line;
   begin
      OLED.Clear;

      --  Top Header Bar (Clean & Minimal)
      OLED.Paint_Text (5, 1, "09:41", Color => On);

      --  Battery indicator on the right
      OLED.Paint_Rectangle (108, 1, 14, 7);
      OLED.Paint_Pixel (122, 3, On);
      OLED.Paint_Pixel (122, 4, On);
      OLED.Paint_Pixel (122, 5, On);
      OLED.Paint_Filled_Rectangle (110, 3, 9, 3);

      --  Header divider line
      OLED.Paint_Line (3, 9, 124, 9);

      --  1. Top-Left Bento Card: HOME (X=3..53, Y=12..34)
      declare
         Active : constant Boolean := (Sel = 0);
         Fg     : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (3, 12, 51, 23);
         else
            OLED.Paint_Rectangle (3, 12, 51, 23);
         end if;

         --  Chimney on the roof (X=16)
         Draw_VLine (16, 16, 4, Fg);

         --  House Roof (Peak at 14, 17)
         Draw_Line (14, 17, 10, 21, Fg);
         Draw_Line (14, 17, 18, 21, Fg);
         Draw_HLine (10, 21, 9, Fg);

         --  House Body & Base
         Draw_VLine (11, 21, 6, Fg);
         Draw_VLine (17, 21, 6, Fg);
         Draw_HLine (11, 26, 7, Fg);

         --  Door
         Draw_VLine (13, 23, 4, Fg);
         Draw_VLine (15, 23, 4, Fg);
         Draw_HLine (13, 23, 3, Fg);

         --  Animated Chimney Smoke and Lit Window when Active
         if Active then
            declare
               S1_Y : constant Integer := 15 - ((Frame mod 6) * 3 / 4);
               S1_X : constant Integer := 16 + ((Frame mod 6) / 2);
               S2_Y : constant Integer := 15 - (((Frame + 3) mod 6) * 3 / 4);
               S2_X : constant Integer := 16 + (((Frame + 3) mod 6) / 2);
            begin
               if S1_Y >= 13 then
                  Draw_Pixel (S1_X, S1_Y, Fg);
               end if;
               if S2_Y >= 13 then
                  Draw_Pixel (S2_X, S2_Y, Fg);
               end if;
            end;
            --  Lit Attic Window in gable
            Draw_Pixel (14, 19, Fg);
         end if;

         OLED.Paint_Text (23, 19, "HOME", Color => Fg);
      end;

      --  2. Top-Right Bento Card: MUSIC (X=56..124, Y=12..34)
      declare
         Active  : constant Boolean := (Sel = 1);
         Fg      : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
         NX      : constant Integer := 69;
         Phase_M : constant Natural := Frame mod 8;
         --  Syncopated bobbing of the two note heads
         B1      : constant Integer :=
           (if Active and then (Phase_M in 2 .. 5) then 1 else 0);
         B2      : constant Integer :=
           (if Active and then (Phase_M in 0 .. 1 or else Phase_M in 6 .. 7)
            then 1 else 0);
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (56, 12, 69, 23);
         else
            OLED.Paint_Rectangle (56, 12, 69, 23);
         end if;

         --  Double Beamed Note Icon (Dancing to the beat when active)
         --  Stem 1 and Head 1 (bobs with B1)
         Draw_VLine (NX + 2, 18 - B1, 7, Fg);
         Draw_HLine (NX, 24 - B1, 4, Fg);
         Draw_HLine (NX, 25 - B1, 4, Fg);

         --  Stem 2 and Head 2 (bobs with B2)
         Draw_VLine (NX + 7, 17 - B2, 7, Fg);
         Draw_HLine (NX + 5, 23 - B2, 4, Fg);
         Draw_HLine (NX + 5, 24 - B2, 4, Fg);

         --  Connecting dynamic top beam (follows both note heads)
         Draw_Line (NX + 2, 18 - B1, NX + 7, 17 - B2, Fg);
         Draw_Line (NX + 2, 19 - B1, NX + 7, 18 - B2, Fg);

         --  Radiating sound vibration accent when active
         if Active and then (Phase_M mod 4 < 2) then
            Draw_Pixel (NX + 9, 15 - B2, Fg);
            Draw_Pixel (NX + 10, 14 - B2, Fg);
         end if;

         --  Centered Text (X=83, baseline matches note head at Y=25)
         OLED.Paint_Text (83, 19, "MUSIC", Color => Fg);
      end;

      --  3. Bottom-Left Bento Card: ALARM (X=3..53, Y=38..60)
      declare
         Active : constant Boolean := (Sel = 3);
         Fg     : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
         AX     : constant Integer := 8;
         AY     : constant Integer := 45;
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (3, 38, 51, 23);
         else
            OLED.Paint_Rectangle (3, 38, 51, 23);
         end if;

         --  Twin-Bell Alarm Clock Icon (Width: 9, Height: 8)
         --  Top bells & snooze button (Row 0..1)
         Draw_HLine (AX, AY, 2, Fg);
         Draw_HLine (AX + 7, AY, 2, Fg);
         Draw_Pixel (AX + 1, AY + 1, Fg);
         Draw_Pixel (AX + 4, AY + 1, Fg);
         Draw_Pixel (AX + 7, AY + 1, Fg);

         --  Round Clock Body (Row 2..6)
         Draw_HLine (AX + 2, AY + 2, 5, Fg);
         Draw_Pixel (AX + 1, AY + 3, Fg);
         Draw_Pixel (AX + 7, AY + 3, Fg);
         Draw_Pixel (AX + 1, AY + 4, Fg);
         Draw_Pixel (AX + 7, AY + 4, Fg);
         Draw_Pixel (AX + 1, AY + 5, Fg);
         Draw_Pixel (AX + 7, AY + 5, Fg);
         Draw_HLine (AX + 2, AY + 6, 5, Fg);

         --  Clock Hands (12:15 - hour hand up, minute hand right)
         Draw_Pixel (AX + 4, AY + 3, Fg);
         Draw_HLine (AX + 4, AY + 4, 2, Fg);

         --  Clock Feet (Row 7)
         Draw_Pixel (AX + 1, AY + 7, Fg);
         Draw_Pixel (AX + 7, AY + 7, Fg);

         --  Ringing vibration waves when active
         if Active and then (Frame mod 4 < 2) then
            Draw_Pixel (AX - 2, AY, Fg);
            Draw_Pixel (AX - 2, AY + 1, Fg);
            Draw_Pixel (AX + 10, AY, Fg);
            Draw_Pixel (AX + 10, AY + 1, Fg);
         end if;

         OLED.Paint_Text (21, 46, "ALARM", Color => Fg);
      end;

      --  4. Bottom-Right Bento Card: SETTINGS (X=56..124, Y=38..60)
      declare
         Active : constant Boolean := (Sel = 2);
         Fg     : constant Glyph.Colors.Monochrome :=
           (if Active then Off else On);
         SX     : constant Integer := 61;
         K1     : constant Integer :=
           (if Active then SX + 2 + ((Frame mod 15) / 3) else SX + 3);
         K2     : constant Integer :=
           (if Active then SX + 8 - ((Frame mod 15) / 3) else SX + 7);
      begin
         if Active then
            OLED.Paint_Filled_Rectangle (56, 38, 69, 23);
         else
            OLED.Paint_Rectangle (56, 38, 69, 23);
         end if;

         --  Slider 1 Track & Knob
         Draw_HLine (SX, 44, 11, Fg);
         Draw_VLine (K1, 42, 5, Fg);
         Draw_VLine (K1 + 1, 42, 5, Fg);

         --  Slider 2 Track & Knob
         Draw_HLine (SX, 52, 11, Fg);
         Draw_VLine (K2, 50, 5, Fg);
         Draw_VLine (K2 + 1, 50, 5, Fg);

         OLED.Paint_Text (75, 46, "SETTINGS", Color => Fg);
      end;
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
      Put_Line ("Rendering SSD1306 Music Player animation (60 frames at 25 FPS)...");

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
