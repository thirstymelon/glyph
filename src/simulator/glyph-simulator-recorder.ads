with Glyph.Colors;
with Glyph.Canvas.C128x64_Mono;
with Glyph.Canvas.C240x320_RGB565;
with Glyph.Simulator.I2C;
with Glyph.Simulator.SPI;
with Glyph.Simulator.Exporter;

package Glyph.Simulator.Recorder is

   type Recorder_T is tagged limited private;

   --  Start a new recording session
   procedure Start
     (This         : in out Recorder_T;
      Session_Name : String := "session");

   --  Capture frame from Simulated I2C Port (Monochrome SSD1306)
   procedure Capture_Frame
     (This     : in out Recorder_T;
      Port     : Glyph.Simulator.I2C.Simulated_I2C_Port;
      Scale    : Positive := 4;
      FG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.OLED_White;
      BG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.Background_Dark);

   --  Capture frame from Simulated SPI Port (Full Color ILI9341)
   procedure Capture_Frame
     (This  : in out Recorder_T;
      Port  : Glyph.Simulator.SPI.Simulated_SPI_Port;
      Scale : Positive := 1);

   --  Capture frame directly from monochrome canvas
   procedure Capture_Frame
     (This     : in out Recorder_T;
      Canvas   : Glyph.Canvas.C128x64_Mono.Instance;
      Scale    : Positive := 4;
      FG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.OLED_White;
      BG_Color : Glyph.Colors.RGB888 := Glyph.Simulator.Exporter.Background_Dark);

   --  Capture frame directly from color RGB565 canvas
   procedure Capture_Frame
     (This   : in out Recorder_T;
      Canvas : Glyph.Canvas.C240x320_RGB565.Instance;
      Scale  : Positive := 1);

   --  Number of frames currently captured in this session
   function Frame_Count (This : Recorder_T) return Natural;

   --  Export recorded frames as an animated GIF file
   procedure Export_GIF
     (This        : in out Recorder_T;
      Output_Path : String;
      FPS         : Positive := 10;
      Keep_Frames : Boolean := True);

   --  Export recorded frames as an MP4 Video file
   procedure Export_Video
     (This        : in out Recorder_T;
      Output_Path : String;
      FPS         : Positive := 30;
      Keep_Frames : Boolean := True);

   --  Clean up session resources and temporary frame files
   procedure Finish (This : in out Recorder_T);

private

   type Recorder_T is tagged limited record
      Active      : Boolean := False;
      Frame_Index : Natural := 0;
      Session_Dir : String (1 .. 1024) := [others => ' '];
      Session_Len : Natural := 0;
   end record;

end Glyph.Simulator.Recorder;
