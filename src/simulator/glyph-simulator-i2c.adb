package body Glyph.Simulator.I2C is

   use HAL;

   function Get_Pixel
     (This : Simulated_I2C_Port; X : Natural; Y : Natural) return Boolean
   is
      Page : Natural;
      Bit  : Natural;
      Byte : HAL.UInt8;
   begin
      if X >= Display_Width or else Y >= Display_Height then
         return False;
      end if;

      Page := Y / 8;
      Bit  := Y mod 8;
      Byte := This.RAM (X, Page);
      return (Byte and HAL.UInt8 (2 ** Bit)) /= 0;
   end Get_Pixel;

   procedure Clear_Memory (This : in out Simulated_I2C_Port) is
   begin
      This.RAM := [others => [others => 0]];
      This.Col_Start := 0;
      This.Col_End := Display_Width - 1;
      This.Page_Start := 0;
      This.Page_End := Total_Pages - 1;
      This.Current_Col := 0;
      This.Current_Page := 0;
   end Clear_Memory;

   function Total_Bytes_Received
     (This : Simulated_I2C_Port) return Natural is
   begin
      return This.Bytes_Received;
   end Total_Bytes_Received;

   function Total_Transfers_Count
     (This : Simulated_I2C_Port) return Natural is
   begin
      return This.Transfers_Count;
   end Total_Transfers_Count;

   procedure Reset_Metrics (This : in out Simulated_I2C_Port) is
   begin
      This.Bytes_Received := 0;
      This.Transfers_Count := 0;
   end Reset_Metrics;

   overriding procedure Master_Transmit
     (This    : in out Simulated_I2C_Port;
      Addr    : HAL.I2C.I2C_Address;
      Data    : HAL.I2C.I2C_Data;
      Status  : out HAL.I2C.I2C_Status;
      Timeout : Natural := 1000)
   is
      pragma Unreferenced (Addr, Timeout);
      Idx : Integer;
      Cmd : HAL.UInt8;
   begin
      Status := HAL.I2C.Ok;
      if Data'Length = 0 then
         return;
      end if;

      This.Bytes_Received := This.Bytes_Received + Data'Length;
      This.Transfers_Count := This.Transfers_Count + 1;

      --  Check Control Byte
      if Data (Data'First) = 16#00# then
         --  Command stream: decode SSD1306 opcodes
         Idx := Data'First + 1;
         while Idx <= Data'Last loop
            Cmd := Data (Idx);
            case Cmd is
               when 16#21# =>
                  --  Set Column Address (3 bytes total: 21h, Col_Start, Col_End)
                  if Idx + 2 <= Data'Last then
                     This.Col_Start := Natural'Min (Display_Width - 1, Natural (Data (Idx + 1)));
                     This.Col_End   := Natural'Min (Display_Width - 1, Natural (Data (Idx + 2)));
                     This.Current_Col := This.Col_Start;
                     Idx := Idx + 3;
                  else
                     Idx := Idx + 1;
                  end if;

               when 16#22# =>
                  --  Set Page Address (3 bytes total: 22h, Page_Start, Page_End)
                  if Idx + 2 <= Data'Last then
                     This.Page_Start := Natural'Min (Total_Pages - 1, Natural (Data (Idx + 1)));
                     This.Page_End   := Natural'Min (Total_Pages - 1, Natural (Data (Idx + 2)));
                     This.Current_Page := This.Page_Start;
                     Idx := Idx + 3;
                  else
                     Idx := Idx + 1;
                  end if;

               when 16#D5# | 16#A8# | 16#D3# | 16#8D# | 16#20#
                  | 16#DA# | 16#81# | 16#D9# | 16#DB# =>
                  --  Two-byte commands: skip parameter byte
                  Idx := Idx + 2;

               when others =>
                  Idx := Idx + 1;
            end case;
         end loop;

      elsif Data (Data'First) = 16#40# then
         --  Data stream: write bytes sequentially into simulated GDDRAM
         for I in Data'First + 1 .. Data'Last loop
            if This.Current_Col < Display_Width and then This.Current_Page < Total_Pages then
               This.RAM (This.Current_Col, This.Current_Page) := Data (I);
            end if;

            --  Advance pointer according to horizontal addressing mode
            if This.Current_Col < This.Col_End then
               This.Current_Col := This.Current_Col + 1;
            else
               This.Current_Col := This.Col_Start;
               if This.Current_Page < This.Page_End then
                  This.Current_Page := This.Current_Page + 1;
               else
                  This.Current_Page := This.Page_Start;
               end if;
            end if;
         end loop;
      end if;
   end Master_Transmit;

   overriding procedure Master_Receive
     (This    : in out Simulated_I2C_Port;
      Addr    : HAL.I2C.I2C_Address;
      Data    : out HAL.I2C.I2C_Data;
      Status  : out HAL.I2C.I2C_Status;
      Timeout : Natural := 1000)
   is
      pragma Unreferenced (This, Addr, Timeout);
   begin
      Data := [others => 0];
      Status := HAL.I2C.Err_Error;
   end Master_Receive;

   overriding procedure Mem_Write
     (This          : in out Simulated_I2C_Port;
      Addr          : HAL.I2C.I2C_Address;
      Mem_Addr      : HAL.UInt16;
      Mem_Addr_Size : HAL.I2C.I2C_Memory_Address_Size;
      Data          : HAL.I2C.I2C_Data;
      Status        : out HAL.I2C.I2C_Status;
      Timeout       : Natural := 1000)
   is
      pragma Unreferenced (This, Addr, Mem_Addr, Mem_Addr_Size, Data, Timeout);
   begin
      Status := HAL.I2C.Err_Error;
   end Mem_Write;

   overriding procedure Mem_Read
     (This          : in out Simulated_I2C_Port;
      Addr          : HAL.I2C.I2C_Address;
      Mem_Addr      : HAL.UInt16;
      Mem_Addr_Size : HAL.I2C.I2C_Memory_Address_Size;
      Data          : out HAL.I2C.I2C_Data;
      Status        : out HAL.I2C.I2C_Status;
      Timeout       : Natural := 1000)
   is
      pragma Unreferenced (This, Addr, Mem_Addr, Mem_Addr_Size, Timeout);
   begin
      Data := [others => 0];
      Status := HAL.I2C.Err_Error;
   end Mem_Read;

end Glyph.Simulator.I2C;
