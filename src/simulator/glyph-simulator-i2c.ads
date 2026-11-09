with HAL;
with HAL.I2C;

package Glyph.Simulator.I2C is

   Display_Width  : constant Positive := 128;
   Display_Height : constant Positive := 64;
   Total_Pages    : constant Positive := 8;

   type Simulated_I2C_Port is limited new HAL.I2C.I2C_Port with private;

   --  Query a pixel in the simulated GDDRAM (0..127, 0..63)
   function Get_Pixel
     (This : Simulated_I2C_Port; X : Natural; Y : Natural) return Boolean;

   --  Reset internal simulated GDDRAM
   procedure Clear_Memory (This : in out Simulated_I2C_Port);

   --  HAL.I2C.I2C_Port interface implementation
   overriding procedure Master_Transmit
     (This    : in out Simulated_I2C_Port;
      Addr    : HAL.I2C.I2C_Address;
      Data    : HAL.I2C.I2C_Data;
      Status  : out HAL.I2C.I2C_Status;
      Timeout : Natural := 1000);

   overriding procedure Master_Receive
     (This    : in out Simulated_I2C_Port;
      Addr    : HAL.I2C.I2C_Address;
      Data    : out HAL.I2C.I2C_Data;
      Status  : out HAL.I2C.I2C_Status;
      Timeout : Natural := 1000);

   overriding procedure Mem_Write
     (This          : in out Simulated_I2C_Port;
      Addr          : HAL.I2C.I2C_Address;
      Mem_Addr      : HAL.UInt16;
      Mem_Addr_Size : HAL.I2C.I2C_Memory_Address_Size;
      Data          : HAL.I2C.I2C_Data;
      Status        : out HAL.I2C.I2C_Status;
      Timeout       : Natural := 1000);

   overriding procedure Mem_Read
     (This          : in out Simulated_I2C_Port;
      Addr          : HAL.I2C.I2C_Address;
      Mem_Addr      : HAL.UInt16;
      Mem_Addr_Size : HAL.I2C.I2C_Memory_Address_Size;
      Data          : out HAL.I2C.I2C_Data;
      Status        : out HAL.I2C.I2C_Status;
      Timeout       : Natural := 1000);

   --  Metrics for performance analysis
   function Total_Bytes_Received (This : Simulated_I2C_Port) return Natural;
   function Total_Transfers_Count (This : Simulated_I2C_Port) return Natural;
   procedure Reset_Metrics (This : in out Simulated_I2C_Port);

private

   type GDDRAM_Array is array (0 .. Display_Width - 1, 0 .. Total_Pages - 1)
     of HAL.UInt8;

   type Simulated_I2C_Port is limited new HAL.I2C.I2C_Port with record
      RAM             : GDDRAM_Array := [others => [others => 0]];
      Col_Start       : Natural := 0;
      Col_End         : Natural := Display_Width - 1;
      Page_Start      : Natural := 0;
      Page_End        : Natural := Total_Pages - 1;
      Current_Col     : Natural := 0;
      Current_Page    : Natural := 0;
      Bytes_Received  : Natural := 0;
      Transfers_Count : Natural := 0;
   end record;

end Glyph.Simulator.I2C;
