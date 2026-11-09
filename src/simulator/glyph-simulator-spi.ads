with HAL;
with HAL.SPI;
with HAL.GPIO;
with Glyph.Colors;

package Glyph.Simulator.SPI is

   Display_Width  : constant Positive := 240;
   Display_Height : constant Positive := 320;

   type Simulated_GPIO_Point is limited new HAL.GPIO.GPIO_Point with private;
   type Any_Simulated_GPIO is access all Simulated_GPIO_Point;

   type Simulated_SPI_Port is limited new HAL.SPI.SPI_Port with private;

   --  Connect simulated DC pin to the SPI port so it can track command vs data
   procedure Connect_DC
     (This : in out Simulated_SPI_Port; DC : Any_Simulated_GPIO);

   --  Query a pixel in the simulated ILI9341 GRAM (0..239, 0..319)
   function Get_Pixel
     (This : Simulated_SPI_Port; X : Natural; Y : Natural) return Glyph.Colors.RGB565;

   --  Reset internal simulated GRAM
   procedure Clear_Memory (This : in out Simulated_SPI_Port);

   --  HAL.SPI.SPI_Port interface implementation
   overriding function Data_Size
     (This : Simulated_SPI_Port) return HAL.SPI.SPI_Data_Size;

   overriding procedure Transmit
     (This    : in out Simulated_SPI_Port;
      Data    : HAL.SPI.SPI_Data_8b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000);

   overriding procedure Transmit
     (This    : in out Simulated_SPI_Port;
      Data    : HAL.SPI.SPI_Data_16b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000);

   overriding procedure Receive
     (This    : in out Simulated_SPI_Port;
      Data    : out HAL.SPI.SPI_Data_8b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000);

   overriding procedure Receive
     (This    : in out Simulated_SPI_Port;
      Data    : out HAL.SPI.SPI_Data_16b;
      Status  : out HAL.SPI.SPI_Status;
      Timeout : Natural := 1000);

   --  HAL.GPIO.GPIO_Point interface implementation
   overriding function Support
     (This : Simulated_GPIO_Point; Capa : HAL.GPIO.Capability) return Boolean;

   overriding function Mode
     (This : Simulated_GPIO_Point) return HAL.GPIO.GPIO_Mode;

   overriding procedure Set_Mode
     (This : in out Simulated_GPIO_Point; Mode : HAL.GPIO.GPIO_Config_Mode);

   overriding function Pull_Resistor
     (This : Simulated_GPIO_Point) return HAL.GPIO.GPIO_Pull_Resistor;

   overriding procedure Set_Pull_Resistor
     (This : in out Simulated_GPIO_Point; Pull : HAL.GPIO.GPIO_Pull_Resistor);

   overriding function Set (This : Simulated_GPIO_Point) return Boolean;
   overriding procedure Set (This : in out Simulated_GPIO_Point);
   overriding procedure Clear (This : in out Simulated_GPIO_Point);
   overriding procedure Toggle (This : in out Simulated_GPIO_Point);

   --  Metrics for performance analysis
   function Total_Bytes_Received (This : Simulated_SPI_Port) return Natural;
   function Total_Transfers_Count (This : Simulated_SPI_Port) return Natural;
   procedure Reset_Metrics (This : in out Simulated_SPI_Port);

   --  Export simulated GRAM to 24-bit full color BMP
   procedure Export_BMP
     (Port      : Simulated_SPI_Port;
      File_Path : String;
      Scale     : Positive := 1);

   --  Export simulated GRAM to animated GIF
   procedure Export_GIF
     (Port         : Simulated_SPI_Port;
      File_Path    : String;
      Scale        : Positive := 1;
      Duration_Sec : Positive := 2);

   --  Export simulated GRAM to MP4 Video
   procedure Export_Video
     (Port         : Simulated_SPI_Port;
      File_Path    : String;
      Scale        : Positive := 1;
      Duration_Sec : Positive := 3;
      FPS          : Positive := 30);

private

   type GRAM_Array is array (0 .. Display_Width - 1, 0 .. Display_Height - 1)
     of Glyph.Colors.RGB565;

   type Simulated_GPIO_Point is limited new HAL.GPIO.GPIO_Point with record
      State     : Boolean := False;
      Curr_Mode : HAL.GPIO.GPIO_Mode := HAL.GPIO.Output;
      Resistor  : HAL.GPIO.GPIO_Pull_Resistor := HAL.GPIO.Floating;
   end record;

   type Simulated_SPI_Port is limited new HAL.SPI.SPI_Port with record
      GRAM            : GRAM_Array := [others => [others => 16#0000#]];
      Col_Start       : Natural := 0;
      Col_End         : Natural := Display_Width - 1;
      Row_Start       : Natural := 0;
      Row_End         : Natural := Display_Height - 1;
      Current_X       : Natural := 0;
      Current_Y       : Natural := 0;
      Current_Command : HAL.UInt8 := 0;
      Cmd_Param_Idx   : Natural := 0;
      High_Byte       : HAL.UInt8 := 0;
      Have_High_Byte  : Boolean := False;
      DC_Pin          : Any_Simulated_GPIO := null;
      Bytes_Received  : Natural := 0;
      Transfers_Count : Natural := 0;
   end record;

end Glyph.Simulator.SPI;
