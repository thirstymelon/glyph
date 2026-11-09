with Glyph.Colors;
with Glyph.Canvas.C128x64_Mono;
with Glyph.Simulator.I2C;

package Glyph.Simulator.Exporter is

   --  OLED Color Themes for Exported Images
   OLED_White : constant Glyph.Colors.RGB888 := (Red => 255, Green => 255, Blue => 255);
   OLED_Blue  : constant Glyph.Colors.RGB888 := (Red => 0,   Green => 229, Blue => 255);
   OLED_Amber : constant Glyph.Colors.RGB888 := (Red => 255, Green => 176, Blue => 0);
   OLED_Green : constant Glyph.Colors.RGB888 := (Red => 0,   Green => 255, Blue => 102);

   Background_Dark : constant Glyph.Colors.RGB888 := (Red => 10, Green => 10, Blue => 10);

   --  Export simulated display to standard Windows 24-bit BMP image
   procedure Export_BMP
     (Port      : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path : String;
      Scale     : Positive := 4;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark);

   procedure Export_BMP
     (Canvas    : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path : String;
      Scale     : Positive := 4;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark);

   --  Export simulated display to standard Portable Pixmap (PPM P6) image
   procedure Export_PPM
     (Port      : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path : String;
      Scale     : Positive := 1;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark);

   procedure Export_PPM
     (Canvas    : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path : String;
      Scale     : Positive := 1;
      FG_Color  : Glyph.Colors.RGB888 := OLED_White;
      BG_Color  : Glyph.Colors.RGB888 := Background_Dark);

   --  Export simulated display as an animated GIF file
   procedure Export_GIF
     (Port         : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 2;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark);

   procedure Export_GIF
     (Canvas       : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 2;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark);

   --  Export simulated display as an MP4 Video file
   procedure Export_Video
     (Port         : Glyph.Simulator.I2C.Simulated_I2C_Port;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 3;
      FPS          : Positive := 30;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark);

   procedure Export_Video
     (Canvas       : Glyph.Canvas.C128x64_Mono.Instance;
      File_Path    : String;
      Scale        : Positive := 4;
      Duration_Sec : Positive := 3;
      FPS          : Positive := 30;
      FG_Color     : Glyph.Colors.RGB888 := OLED_White;
      BG_Color     : Glyph.Colors.RGB888 := Background_Dark);

end Glyph.Simulator.Exporter;
